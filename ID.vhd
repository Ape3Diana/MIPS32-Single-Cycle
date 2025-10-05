----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2025 04:38:21 PM
-- Design Name: 
-- Module Name: ID - Behavioral
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

entity ID is Port (
    clk: in std_logic;
    RegWrite: in std_logic;
    instr: in std_logic_vector(25 downto 0);
    RegDst: in std_logic;
    en: in std_logic;
    ExtOp: in std_logic;
    WD: in std_logic_vector(31 downto 0);
    RD1: out std_logic_vector(31 downto 0);
    RD2: out std_logic_vector(31 downto 0);
    Ext_Imm: out std_logic_vector(31 downto 0);
    func: out std_logic_vector(5 downto 0);
    sa: out std_logic_vector(4 downto 0));
end ID;

architecture Behavioral of ID is

component reg_file is port ( 
        clk : in std_logic;
        en: in std_logic;
        ra1 : in std_logic_vector(4 downto 0);
        ra2 : in std_logic_vector(4 downto 0);
        wa : in std_logic_vector(4 downto 0);
        wd : in std_logic_vector(31 downto 0);
        regwr : in std_logic;
        rd1 : out std_logic_vector(31 downto 0);
        rd2 : out std_logic_vector(31 downto 0));
end component;

signal WriteAddress: std_logic_vector(4 downto 0) := (others=>'0');

begin

    cRegFile: reg_file port map (clk, en, instr(25 downto 21),instr(20 downto 16), WriteAddress, WD, RegWrite, RD1, RD2);
    
    cMUX: WriteAddress <= instr(20 downto 16) when RegDst = '0' else instr(15 downto 11);
    
    cExtUnit: Ext_Imm <= X"0000" & instr(15 downto 0) when ExtOp = '0' else 
                (15 downto 0 => instr(15)) & instr(15 downto 0);
    
    func <= instr(5 downto 0);
    sa <= instr(10 downto 6);

end Behavioral;
