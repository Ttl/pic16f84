LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY  cpu_core_testbranch_tb IS
END  cpu_core_testbranch_tb;
 
ARCHITECTURE behavior OF cpu_core_testbranch_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpu_core
    GENERIC( instruction_file : string);
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         porta : INOUT  std_logic_vector(4 downto 0);
         portb : INOUT  std_logic_vector(7 downto 0);
         pc_out : OUT  std_logic_vector(12 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

	--BiDirs
   signal porta : std_logic_vector(4 downto 0);
   signal portb : std_logic_vector(7 downto 0);

 	--Outputs
   signal pc_out : std_logic_vector(12 downto 0);

   -- Clock period definitions
   constant clk_period : time := 31.25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpu_core 
   Generic map(instruction_file => "scripts/instructions_testbranch.mif")
   PORT MAP (
          clk => clk,
          reset => reset,
          porta => porta,
          portb => portb,
          pc_out => pc_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      reset <= '1';
      wait for clk_period*10;
      wait until rising_edge(clk);
      reset <= '0';
      wait for clk_period/2;
      wait for clk_period*10;
      assert unsigned(pc_out) > to_unsigned(9,13) report "First branch not cleared" severity failure;
      wait for clk_period*14;
      assert portb /= "00010110" report "Instruction not skipped" severity failure;
      assert unsigned(pc_out) > to_unsigned(21,13) report "PCL update failed" severity failure;
      wait for clk_period*5;
      assert portb = "11111111" report "Instruction not skipped" severity failure;
      wait for clk_period*8;
      assert portb = "00000011" report "Instruction not skipped (Call/return)" severity failure;
      wait for clk_period*4;
      assert portb = "00000011" report "Instruction not skipped (goto)" severity failure;
      
      reset <= '1';
      wait for clk_period;
      assert false report "Succesfully completed" severity failure;
   end process;

END;
