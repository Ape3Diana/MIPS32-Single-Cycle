----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2025 11:32:43 AM
-- Design Name: 
-- Module Name: EX - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EX is Port (
            RD1: in std_logic_vector(31 downto 0);
            ALUSrc: in std_logic;
            RD2: in std_logic_vector(31 downto 0);
            Ext_Imm: in std_logic_vector(31 downto 0);
            sa: in std_logic_vector(4 downto 0);
            func: in std_logic_vector(5 downto 0);
            ALUOp: in std_logic_vector(1 downto 0);
            PC_plus4: in std_logic_vector(31 downto 0);
            zero_beq: out std_logic;
            zero_bne: out std_logic;
            ALURes: out std_logic_vector(31 downto 0);
            Branch_Address: out std_logic_vector(31 downto 0)
             );
end EX;

architecture Behavioral of EX is

signal B: std_logic_vector(31 downto 0) := (others => '0');
signal ALUCtrl: std_logic_vector(2 downto 0) := (others => '0');

begin

    cMUX: B <= RD2 when ALUSrc = '0' else Ext_Imm;
    
    cSum: Branch_Address <= (Ext_Imm(29 downto 0) & "00") + PC_plus4;
    
    cALUControl: process(ALUOp, func)
    begin
        case ALUOp is
            when "10" => --R
                case func is
                    when "100000" => ALUCtrl  <= "000"; -- (+) --add
                    when "100010" => ALUCtrl  <= "100"; -- (-) --sub
                    when "000000" => ALUCtrl  <= "101"; -- (<<l) --sll
                    when "000010" => ALUCtrl  <= "110"; -- (>>l) --srl
                    when "100100" => ALUCtrl  <= "001"; -- (&) --and
                    when "100101" => ALUCtrl  <= "010"; -- (|) --or
                    when "000011" => ALUCtrl  <= "111"; -- (>>a) --sra
                    when "100110" => ALUCtrl  <= "011"; -- (^) --xor
                    when others => null;
                end case; 
            when "00" => ALUCtrl  <= "000"; -- (+) 
            when "01" => ALUCtrl  <= "100"; -- (-) 
            when "11" => ALUCtrl  <= "010"; -- (|)
            when others => null;
        end case;
    end process; 
    
    cALU: process(ALUCtrl, RD1, B)
    begin
        zero_beq <= '0';
        zero_bne <= '0';
        case ALUCtrl is
            when "000" => ALURes <= RD1 + B; --(+)
            when "001" => ALURes <= RD1 and B; --(&)
            when "010" => ALURes <= RD1 or B; --(|)
            when "011" => ALURes <= RD1 xor B; --(^)
            when "100" => 
                ALURes <= B - RD1; --(-)   -- doar testam egalitatea, adica daca avem sau nu 0, pot interschimba termenii
                -- doar in cazul acestei implementeri, pentru ca scaderea nu se foloseste in alta parte
                -- ca sa conteze ordinea
                if (B - RD1 = X"00000000") then zero_beq <= '1';
                else zero_bne <= '1';
                end if;
            when "101" => ALURes <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa)) ; --(<<l)
            when "110" => ALURes <= to_stdlogicvector(to_bitvector(B) srl conv_integer(sa)) ; --(>>l)
            when "111" => ALURes <= to_stdlogicvector(to_bitvector(B) sra conv_integer(sa)) ; --(>>a)
            when others => null;
          end case;
   end process;


end Behavioral;
