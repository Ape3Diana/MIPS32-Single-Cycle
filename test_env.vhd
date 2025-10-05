----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/28/2025 05:08:19 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
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

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component IFetch is Port ( 
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
end component;

component ID is Port (
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
end component;

component EX is Port (
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
end component;

component MEM is Port ( 
                MemWrite: in std_logic;
                ALURes_in: in std_logic_vector(31 downto 0);
                RD2: in std_logic_vector(31 downto 0);
                clk: in std_logic;
                EN: in std_logic;
                MemData: out std_logic_vector(31 downto 0);
                ALURes_out: out std_logic_vector(31 downto 0)
                );
end component;

signal RD1: std_logic_vector(31 downto 0) := (others=>'0');
signal RD2: std_logic_vector(31 downto 0) := (others=>'0');
signal ALUSrc: std_logic := '0';
signal Ext_Imm: std_logic_vector(31 downto 0) := (others=>'0');
signal sa: std_logic_vector(4 downto 0) := (others=>'0');
signal func: std_logic_vector(5 downto 0) := (others=>'0');
signal ALUOp: std_logic_vector(1 downto 0) := (others=>'0');
signal pc_plus4: std_logic_vector(31 downto 0) := (others=>'0');
signal zero_beq: std_logic := '0';
signal zero_bne: std_logic := '0';
signal ALURes: std_logic_vector(31 downto 0) := (others=>'0');
signal Branch_Address: std_logic_vector(31 downto 0) := (others=>'0');
signal MemWrite: std_logic := '0';
signal en: std_logic := '0';
signal ALURes_out: std_logic_vector(31 downto 0) := (others=>'0');
signal MemData: std_logic_vector(31 downto 0) := (others=>'0');
signal Jump: std_logic := '0';
signal instr: std_logic_vector(31 downto 0) := (others=>'0');
signal PCSrc: std_logic := '0';
signal WD: std_logic_vector(31 downto 0) := (others=>'0');
signal RegDst: std_logic := '0';
signal ExtOp: std_logic := '0';
signal Branch: std_logic := '0';
signal Br_ne: std_logic := '0';
signal MemtoReg: std_logic := '0';
signal RegWrite: std_logic := '0';
signal sDigits: std_logic_vector(31 downto 0) := (others=>'0');



begin    
    UC: process(instr)
    begin
        RegDst    <= '0';
        RegWrite  <= '0';
        ALUOp     <= "00";
        ExtOp     <= '0';
        ALUSrc    <= '0';
        MemtoReg  <= '0';
        MemWrite  <= '0';
        Branch    <= '0';
        Br_ne     <= '0';
        Jump      <= '0';
        case instr(31 downto 26) is
            when "000000" => --R type
                RegDst <= '1';
                RegWrite <= '1';
                ALUOp <= "10";
            when "001000" => --ADDI
                ExtOp <= '1';
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "00";
           when "100011" => --LW
                ExtOp <= '1';
                ALUSrc <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
                ALUOp <= "00";
           when "101011" => --SW
                ExtOp <= '1';
                ALUSrc <= '1';
                MemWrite <= '1';
                ALUOp <= "00";     
           when "000100" => --BEQ
                ExtOp <= '1';
                Branch <= '1';
                ALUOp <= "01";   
           when "001101" => --ORI
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "11"; 
            when "000101" => --BNE
                ExtOp <= '1';
                Br_ne <= '1';
                ALUOp <= "01";  
            when "000010" => --JUMP
                Jump <= '1';  
            when others => null;
        end case;
    end process; 
    
    cIF: IFetch port map(Jump,
                         instr(31 downto 28) & (instr(25 downto 0) & "00"),
                         PCSrc,
                         Branch_Address,
                         en,
                         btn(1),
                         clk,
                         pc_plus4,
                         instr);
                          
    cID: ID port map(clk,
                     RegWrite,
                     instr(25 downto 0),
                     RegDst,
                     en,
                     ExtOp,
                     WD,
                     RD1,
                     RD2,
                     Ext_Imm,
                     func,
                     sa); 
                        
    cEX: EX port map(RD1,
                    ALUSrc,
                    RD2,
                    Ext_Imm,
                    sa,
                    func,
                    ALUOp,
                    pc_plus4,
                    zero_beq,
                    zero_bne,
                    ALURes,
                    Branch_Address); 
                    
    cMEM: MEM port map(MemWrite,
                        ALURes,
                        RD2,
                        clk,
                        en,
                        MemData,
                        ALURes_out);
                        
    cMPG: MPG port map (en,
                        btn(0),
                        clk);    
                         
                         
    PCSrc <= (Branch and zero_beq) or (Br_ne and zero_bne);
    cMUX_MEM: WD <= ALURes_out when MemtoReg = '0' else MemData;          
              
                            
    --leds
    led(0) <= RegWrite;
    led(1) <= MemtoReg;
    led(2) <= MemWrite;
    led(3) <= Jump;
    led(4) <= Branch;
    led(5) <= ALUSrc;
    led(6) <= ExtOp;
    led(7) <= RegDst;    
    led(8) <= Br_ne;
    led(10 downto 9) <= ALUOp;         
     
    
    
    
    cMUX_SSD: process(sw(7 downto 5))
    begin
        case sw(7 downto 5) is
                when "000" => sDigits <= instr;
                when "001" => sDigits <= pc_plus4;
                when "010" => sDigits <= RD1;
                when "011" => sDigits <= RD2;
                when "100" => sDigits <= Ext_Imm;
                when "101" => sDigits <= ALURes;
                when "110" => sDigits <= MemData;
                when "111" => sDigits <= WD;
                when others => null;
        end case;
    end process;
    
    cSSD: SSD port map(clk,
                        sDigits,
                        an,
                        cat);
       
end Behavioral;
