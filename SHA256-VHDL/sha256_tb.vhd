library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sha256_tb is
    -- No ports for a testbench
end sha256_tb;

architecture Behavioral of sha256_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component SHA256
        Port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            start      : in  std_logic;
            data_in    : in  std_logic_vector(511 downto 0);
            hash_out   : out std_logic_vector(255 downto 0);
            done       : out std_logic
        );
    end component;

    -- Signals for connecting to the UUT
    signal clk        : std_logic := '0';
    signal reset      : std_logic := '0';
    signal start      : std_logic := '0';
    signal data_in    : std_logic_vector(511 downto 0) := (others => '0');
    signal hash_out   : std_logic_vector(255 downto 0);
    signal done       : std_logic;

    -- Test data
    constant test_input : std_logic_vector(511 downto 0) := 
        x"6162638000000000000000000000000000000000000000000000000000000000" &
        x"0000000000000000000000000000000000000000000000000000000000000018"; -- "abc"
    constant expected_hash : std_logic_vector(255 downto 0) := 
        x"BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD"; -- Expected SHA-256 hash of "abc"

    -- Clock generation
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the UUT
    uut: SHA256
        Port Map (
            clk      => clk,
            reset    => reset,
            start    => start,
            data_in  => data_in,
            hash_out => hash_out,
            done     => done
        );

    -- Clock process
    clk_process: process
    begin
        while True loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Initialize inputs
        reset <= '1';
        start <= '0';
        data_in <= (others => '0');
        wait for clk_period;

        reset <= '0';
        wait for clk_period;

        -- Apply test input
        data_in <= test_input;
        start <= '1';
        wait for clk_period;
        start <= '0';

        -- Wait for processing to complete
        wait until done = '1';
        wait for clk_period;

        -- Check the output hash
        assert hash_out = expected_hash
        report "Test Passed: Hash matches expected value."
        severity note;

        if hash_out /= expected_hash then
            report "Test Failed: Hash does not match expected value."
            severity error;
        end if;

        -- End simulation
        wait for 10 * clk_period;
        report "Simulation finished." severity note;
        wait;
    end process;

end Behavioral;
