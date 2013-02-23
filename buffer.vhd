library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.picpkg.all;

entity ctrl_buf is
    Port ( clk : in  STD_LOGIC;
           amux : in STD_LOGIC_VECTOR(1 downto 0);
           bmux, writew, rwmux: in  STD_LOGIC;
           alu_op : in alu_ctrl;
           instr10 : in STD_LOGIC_VECTOR(10 downto 0);
           status_write : in STD_LOGIC_VECTOR(4 downto 0);
           amux_ex : out STD_LOGIC_VECTOR(1 downto 0);
           bmux_ex, writew_ex, rwmux_ex : out STD_LOGIC;
           alu_op_ex : out alu_ctrl;
           instr10_ex : out STD_LOGIC_VECTOR(10 downto 0);
           status_write_ex : out STD_LOGIC_VECTOR(4 downto 0));
end ctrl_buf;

architecture Behavioral of ctrl_buf is

begin

process(clk)
begin
if rising_edge(clk) then
    amux_ex <= amux;
    bmux_ex <= bmux;
    writew_ex <= writew;
    rwmux_ex <= rwmux;
    alu_op_ex <= alu_op;
    instr10_ex <= instr10;
    status_write_ex <= status_write;
end if;
end process;

end Behavioral;

