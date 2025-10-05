----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2025 04:37:12 PM
-- Design Name: 
-- Module Name: IFetch - Behavioral
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

entity IFetch is Port ( 
        jump: in std_logic;
        jump_address: in std_logic_vector(31 downto 0);
        pcsrc: in std_logic;
        branch_address: in std_logic_vector(31 downto 0);
        en: in std_logic;
        rst: in std_logic;
        clk: in std_logic;
        pc_plus_4: out std_logic_vector(31 downto 0);
        instruction: out std_logic_vector(31 downto 0)
        );
end IFetch;

architecture Behavioral of IFetch is

type ROM is array (0 to 31) of std_logic_vector(31 downto 0); 
signal mem: ROM := (
        --0
        --lw $1, 0($zero) => load A(numbers starting address)	
        --$1 <- MEM[$0 + SE(0)]; PC <- PC +4;
        --100011_00000_00001_0000000000000000
        --8C010000
        "10001100000000010000000000000000",
        
        --1
        --lw $2, 4($zero) => load N
        --$2 <- MEM[$0 + SE(4)]; PC <- PC +4;
        --100011_00000_00010_0000000000000100
        --8C020004
        "10001100000000100000000000000100",
        
        --2
        --addi $3, $zero, 1 => fib(1)
        --$3 ? $0 + SE(1); PC ? PC + 4;
        --001000_00000_00011_0000000000000001
        --20030001
        "00100000000000110000000000000001",
        
        --3
        --addi $4, $zero, 1 => fib(2)
        --$4 ? $0 + SE(1); PC ? PC + 4;
        --001000_00000_00100_0000000000000001
        --20040001
        "00100000000001000000000000000001",
        
        --4
        --sll $3, $3, 3 => fib(1)*8
        --$3 ? $3 << 3; PC ? PC + 4;
        --000000_00000_00011_00011_00011_000000
        "00000000000000110001100011000000",
        
        --5
        --sll $4, $4, 3 => fib(2)*8	
        --$4 ? $4 << 3; PC ? PC + 4;
        --000000_00000_00100_00100_00011_000000
        --318C0
        "00000000000001000010000011000000",
        
        --6
        --sw $3, 0($1) => store fib(1) at address A
        --MEM[$1 + SE(0)] ? $3; PC ? PC + 4;
        --101011_00001_00011_0000000000000000
        --AC230000
        "10101100001000110000000000000000",
        
        --7
        --addi $1, $1, 4 => next address A
        --$1 ? $1 + SE(4); PC ? PC + 4;
        --001000_00001_00001_0000000000000100
        --20210004
        "00100000001000010000000000000100",
        
        --8
        --sw $4, 0($1) => store fib(2) at address A
        --MEM[$1 + SE(0)] ? $4; PC ? PC + 4;
        --101011_00001_00100_0000000000000000
        --AC240000
        "10101100001001000000000000000000",
        
        --9
        --addi $1, $1, 4 => next address A
        --$1 ? $1 + SE(4); PC ? PC + 4;
        --001000_00001_00001_0000000000000100	
        --20210004
        "00100000001000010000000000000100",
            
        --10
        --addi $5, $zero, 3 => i=3
        --$5 ? $0 + SE(3); PC ? PC + 4;
        --001000_00000_00101_0000000000000011
        --20050003
        "00100000000001010000000000000011",
        
        --11
        --addi $2, $2, 1 => need n+1 for the loop
        --$2 ? $2 + SE(1); PC ? PC + 4;
        --001000_00010_00010_0000000000000001
        --20420001
        "00100000010000100000000000000001",
        
        
        --fib_loop:
        --12
        --beq $5, $2, 13(end) 
        --if $5 = $2 then PC ? (PC + 4) + (SE(13) << 2) else PC ? PC + 4;
        --000100_00101_00010_0000000000001101
        --10A2000D
        "00010000101000100000000000001101",
            
        --13
        --addi $1, $1, -8 => modify A address to read from mem fib(n-2)
        --$1 ? $1 + SE(-8); PC ? PC + 4; 
        --001000_00001_00001_1111111111111000	
        --2021FFF8
        "00100000001000011111111111111000",
        
        --14
        --lw $3, 0($1) => load fib(n-2)*8
        --$3 <- MEM[$1 + SE(0)]; PC <- PC +4;
        --100011_00001_00011_0000000000000000	
        --8C230000
        "10001100001000110000000000000000",
        
        --15
        --srl $3, $3, 3 => fib(n-2)
        --$3 ? $3 >> 3; PC ? PC + 4;
        --000000_00000_00011_00011_00011_000010
        --318C2
        "00000000000000110001100011000010",
        
        --16
        --addi $1, $1, 4 => modify A address to read from mem fib(n-1)	
        --$1 ? $1 + SE(4); PC ? PC + 4
        --001000_00001_00001_0000000000000100 
        --20210004
        "00100000001000010000000000000100",
        
        --17
        --lw $4, 0($1) => load fib(n-1)*8	
        --$4 <- MEM[$1 + SE(0)]; PC <- PC +4;
        --100011_00001_00100_0000000000000000
        --8C240000
        "10001100001001000000000000000000",
        
        --18		
        --srl $4, $4, 3 => fib(n-1)
        --$4 ? $4 >> 3; PC ? PC + 4;
        --000000_00000_00100_00100_00011_000010
        --420C2
        "00000000000001000010000011000010",
        
        --19
        --addi $1, $1, 4 => A address where we put fib(n)
        --$1 ? $1 + SE(4); PC ? PC + 4
        --001000_00001_00001_0000000000000100 	
        --20210004
        "00100000001000010000000000000100",
        
        --20
        --add $6, $3, $4 => fib(n)	
        --$6 ? $3 + $4; PC ? PC + 4;
        --000000_00011_00100_00110_00000_100000
        --643020
        "00000000011001000011000000100000",
        
        --21
        --sll $6, $6, 3 => fib(n)*8	
        --$6 ? $6 << 3; PC ? PC + 4;
        --000000_00000_00110_00110_00011_000000
        --630C0
        "00000000000001100011000011000000",
        
        --22
        --sw $6, 0($1) => store fib(n)*8 
        --MEM[$1 + SE(0)] ? $6; PC ? PC + 4;
        --101011_00001_00110_0000000000000000
        "10101100001001100000000000000000",
        
        --23
        --addi $1, $1, 4 => next address A
        --$1 ? $1 + SE(4); PC ? PC + 4
        --001000_00001_00001_0000000000000100 	
        --20210004
        "00100000001000010000000000000100",
        
        --24
        --addi $5, $5, 1 => i++	
        --001000_00101_00101_0000000000000001
        --20A50001
        "00100000101001010000000000000001",
        
        --25
        --j 12(fib_loop) => jump cu adresa absoluta
        --PC ? (PC + 4)[31:28] || (12 << 2);
        --000010_00000000000000001100	
        --800000C
        "00001000000000000000000000001100",
        
        --end:
        others => "00000000000000000000000000000000"
);

signal pc_q : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal buf_pc_plus_4 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal mux1_mux2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal pc_d : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin

cPC: process(clk)
    begin
        if rst = '1' then 
           pc_q <= (others => '0'); 
        elsif rising_edge(clk) and en = '1'  then
           pc_q <= pc_d;
        end if;
    end process;
    
cMux1: mux1_mux2 <= branch_address when pcsrc = '1' else buf_pc_plus_4;
cMux2: pc_d <= jump_address when jump = '1' else mux1_mux2;

cSum: buf_pc_plus_4 <= pc_q + 4;

cROM: instruction <= mem(conv_integer(pc_q(6 downto 2))); 

cPc_plus_4: pc_plus_4 <= buf_pc_plus_4;

end Behavioral;
