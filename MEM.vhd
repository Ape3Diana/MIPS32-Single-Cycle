----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2025 12:48:10 PM
-- Design Name: 
-- Module Name: MEM - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEM is Port ( 
                MemWrite: in std_logic;
                ALURes_in: in std_logic_vector(31 downto 0);
                RD2: in std_logic_vector(31 downto 0);
                clk: in std_logic;
                EN: in std_logic;
                MemData: out std_logic_vector(31 downto 0);
                ALURes_out: out std_logic_vector(31 downto 0)
                );
end MEM;

architecture Behavioral of MEM is

type RAM is array (0 to 63) of std_logic_vector(31 downto 0); 
signal mem: RAM := (
    "00000000000000000000000000001000", --starting writing address, addr=8
    "00000000000000000000000000000101", --N=5
    --"00000000000000000000000000000000",
    --"00000000000000000000000000000000",
    --"00000000000000000000000000000000", --N=5
    others => "00000000000000000000000000000000"
);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if EN= '1' and MemWrite = '1' then
                mem(conv_integer(ALURes_in(7 downto 2))) <= RD2;
            end if;
        end if; 
    end process;
    
    MemData <= mem(conv_integer(ALURes_in(7 downto 2)));
    
    ALURes_out <= ALURes_in;

end Behavioral;
