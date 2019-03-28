library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity CPU is
	port (
		CLR,		--��λ�źţ��͵�ƽ��Ч
		C,			--��λ��׼
		Z,			--���־
		T3,			--T3ʱ��
		W1,			--W1�������
		W2,			--W2�������
		W3			--W3�������
		: in std_logic;
		IRH			--IR7654
		: in std_logic_vector(3 downto 0);
		SWCBA		--ABģʽ����ֵ,CΪ1ʱΪʵ��̨�����߼�ʵ��
		: in std_logic_vector(2 downto 0);
		SELCTL,		--Ϊ1ʱΪ����̨����
		ABUS,		--Ϊ1ʱ�������������������
		M,			--
		SEL1,		--�൱�ڿ���̨��ʽ��ָ�������IR3210
		SEL0,
		SEL2,
		SEL3,
		DRW,		--Ϊ1ʱ�����Ĵ�������
		SBUS,		--Ϊ1ʱ�������ݿ���ֵ����������
		LIR,		--Ϊ1ʱ���Ӵӳ��ڶ�����ָ�������Ĵ���
		MBUS,		--Ϊ1ʱ���Ӵ洢������������������������
		MEMW,		--Ϊ1ʱ��T2д�洢����Ϊ0ʱ���洢��
		LAR,		--Ϊ1ʱ��T2�������ؽ����������ϵĵ�ַ�����ַ�Ĵ���
		ARINC,		--Ϊ1ʱ��T2�������ص�ַ�Ĵ�����һ
		LPC,		--Ϊ1ʱ��T2�������ص�ַ�����������ϵ����ݴ���PC
		PCINC,		--Ϊ1ʱ��T2��������PC+1
		PCADD,
		CIN,
		LONG,
		SHORT,
		STOP,		--�۲�ʹ��
		LDC,		--Ϊ1ʱT3�������ر����λ
		LDZ			--Ϊ1ʱT3�������ر�����Ϊ0�ı�־
		: out std_logic;
		S			--S3210
		: out std_logic_vector(3 downto 0);
		CP1,CP2,CP3 : out std_logic;
		QD : in std_logic
	);
end CPU;

architecture arc of CPU is
signal ST0,ST0_REG,SST0,STOP_REG,STOP_REG_REG: std_logic;
begin
	CP1<='1';
	CP2<='1';
	with SWCBA select
	STOP<= '0'							when "000",
			STOP_REG or STOP_REG_REG 	when others;
	CP3<=QD;
	ST0<=ST0_REG;

	process (CLR, T3)
	begin
		if (CLR = '0') then
			ST0_REG <= '0';
			STOP_REG_REG <= '1';
		elsif (SST0 = '1') then
			ST0_REG <= '1';
		end if;
	end process;
	
	process (SWCBA, IRH, W1, W2, W3, ST0, C, Z)
	begin
		SHORT <= '0';
		LONG <= '0';
		CIN <= '0';
		SELCTL <= '0';
		ABUS <= '0';
		SBUS <= '0';
		MBUS <= '0';
		M <= '0';
		S <= "0000";
		SEL3 <= '0';
		SEL2 <= '0';
		SEL1 <= '0';
		SEL0 <= '0';
		LIR <= '0';
		MEMW <= '0';
		LAR <= '0';
		ARINC <= '0';
		LPC <= '0';
		LDZ <= '0';
		LDC <= '0';
		STOP_REG <= '0';
		PCINC <= '0';
		SST0 <= '0';
		PCADD <= '0';
		case SWCBA is
			when "000"=>  --ִ�г���
				case ST0 is
					when '0' =>
						-- load pc
						LPC <= W1;
						SBUS <= W1;
						SST0 <= W1;
						SHORT <= W1;
						STOP_REG <= '0';
					when '1' =>
						case IRH is
							when "0001" =>  --ADD ()
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- ѡ��ӷ�
								-- ѡ����������, M�Ѿ�����ʼ��Ϊ0
								S <= "1001";
								
								-- �ӷ�����
								ABUS <= W2;
								DRW <= W2;
								LDZ <= W2;
								LDC <= W2;
							
							when "0010" =>  -- SUB ()
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- ѡ����������, ѡ�����
								-- M�Ѿ�����ʼ��Ϊ0
								S <= "0110";
								
								-- ��������
								ABUS <= W2;
								DRW <= W2;
								LDZ <= W2;
								LDC <= W2;
							when "0011" =>  -- AND ()
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- ѡ���߼�����, ������
								M <= W2;
								S <= "1011";
								
								ABUS <= W2;
								DRW <= W2;
								LDZ <= W2;
							when "0100" =>  -- INC ()
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- ѡ����������, ������
								-- M�Ѿ�����ʼ��Ϊ0
								S <= "0000";
								
								ABUS <= W2;
								DRW <= W2;
								LDZ <= W2;
								LDC <= W2;
								
							when "0101" =>  -- LD
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- ѡ���������㣬����B������ԭֵ��
								M <= W2;
								S <= "1010";
								
								ABUS <= W2;
								LAR <= W2;
								
								-- �ӳ�����
								LONG <= W2;
								
								MBUS <= W3;
								DRW <= W3;
							when "0110" =>  -- ST
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- �趨...
								M <= W2 or W3;
								S <= '1' & W2 & '1' & W2;
								
								ABUS <= W2 or W3;
								LAR <= W2;
								
								-- �ӳ�����
								LONG <= W2;
								
								MEMW <= W3;
							
							when "0111" =>  -- JC
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								PCADD <= C and W2;
							
							when "1000" =>  -- JZ
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								PCADD <= Z and W2;
								
							when "1001" =>  -- JMP
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- �趨��������
								M <= W2;
								S <= "1111";
								
								ABUS <= W2;
								LPC <= W2;
								
							when "1010" =>  -- OUT
								
								-- �趨��������
								M <= W2;
								S <= "1010";
								ABUS <= W2;
							when others =>  -- ��ָ��
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
						end case;
					when others =>
						-- �����ܵ����?
				end case;
			when "001" =>
				SELCTL<=W1;
				SHORT<=W1;
				SBUS<=W1;
				STOP_REG<=W1;
				SST0<=W1;
				LAR<=W1 and (not ST0);
				ARINC<=W1 and ST0;
				MEMW<=W1 and ST0;
			when "010" =>
				SELCTL<=W1;
				SHORT<=W1;
				SBUS<=W1 and (not ST0);
				MBUS<=W1 and ST0;
				STOP_REG<=W1;
				SST0<=W1;
				LAR<=W1 and (not ST0);
				ARINC<=W1 and ST0;
			when "011" =>
				SELCTL<='1';
				SEL0<=W1 or W2;
				STOP_REG<=W1 or W2;
				SEL3<=W2;
				SEL1<=W2;
			when "100" =>
				SELCTL<='1';
				SST0<=W2;
				SBUS<=W1 or W2;
				STOP_REG<=W1 or W2;
				DRW<=W1 or W2;
				SEL3<=(ST0 and W1) or (ST0 and W2);
				SEL2<=W2;
				SEL1<=((not ST0) and W1) or (ST0 and W2);
				SEL0<=W1;
			when others=>
		end case;
	end process;
end arc;





