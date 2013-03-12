LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY cpu_core_testalu_tb IS
END cpu_core_testalu_tb;
 
ARCHITECTURE behavior OF cpu_core_testalu_tb IS 
 
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
   Generic map(instruction_file => "scripts/instructions_testalu.mif")
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
      wait until pc_out = std_logic_vector(to_unsigned(14,13));
      assert portb = std_logic_vector(to_unsigned(2,8)) report "Line 11, incf result wrong" severity failure;
      wait until pc_out = std_logic_vector(to_unsigned(17,13));
      assert portb = std_logic_vector(to_unsigned(0,8)) report "Line 14, subwf result wrong" severity failure;
      wait until pc_out = std_logic_vector(to_unsigned(20,13));
      assert portb = "00011111" report "Line 17, STATUS wrong" severity failure;
      
      wait until pc_out = std_logic_vector(to_unsigned(24,13));
      assert portb = std_logic_vector(to_unsigned(16,8)) report "Line 21, ADDWF wrong" severity failure;
      
      wait until pc_out = std_logic_vector(to_unsigned(27,13));
      assert portb = "00011010" report "Line 21, STATUS wrong" severity failure;
      
      wait for clk_period;
      reset <= '1';
      assert false report "Success" severity note;

      wait;
   end process;

END;
