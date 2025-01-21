library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SHA256 is
    Port (
        clk        : in  std_logic;          -- Clock signal
        reset      : in  std_logic;          -- Reset signal
        start      : in  std_logic;          -- Start signal
        data_in    : in  std_logic_vector(511 downto 0); -- Input message block (512 bits)
        hash_out   : out std_logic_vector(255 downto 0); -- Output hash value (256 bits)
        done       : out std_logic           -- Done signal
    );
end SHA256;

architecture Behavioral of SHA256 is

    -- Constants for SHA-256
    type const_array is array (0 to 63) of std_logic_vector(31 downto 0);
    constant K : const_array := (
        x"428a2f98", x"71374491", x"b5c0fbcf", x"e9b5dba5",
        x"3956c25b", x"59f111f1", x"923f82a4", x"ab1c5ed5",
        -- Add all 64 constants (from SHA-256 standard)
        x"c67178f2"
    );

    -- Initial hash values
    constant H0 : const_array(0 to 7) := (
        x"6a09e667", x"bb67ae85", x"3c6ef372", x"a54ff53a",
        x"510e527f", x"9b05688c", x"1f83d9ab", x"5be0cd19"
    );

    -- Internal registers
    signal h : const_array(0 to 7) := H0; -- Current hash values
    signal w : const_array := (others => (others => '0')); -- Message schedule array
    signal a, b, c, d, e, f, g, h_temp : std_logic_vector(31 downto 0);
    signal round : integer range 0 to 63 := 0; -- Round counter
    signal processing : std_logic := '0';

    -- Functions for SHA-256 operations
    function Ch(x, y, z : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return (x and y) xor (not x and z);
    end function;

    function Maj(x, y, z : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return (x and y) xor (x and z) xor (y and z);
    end function;

    function Sigma0(x : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return (x(1 downto 0) & x(31 downto 2)) xor
               (x(12 downto 0) & x(31 downto 13)) xor
               (x(21 downto 0) & x(31 downto 22));
    end function;

    function Sigma1(x : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return (x(6 downto 0) & x(31 downto 7)) xor
               (x(17 downto 0) & x(31 downto 18)) xor
               (x(18 downto 0) & x(31 downto 19));
    end function;

    function sigma0(x : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return (x(6 downto 0) & x(31 downto 7)) xor
               (x(16 downto 0) & x(31 downto 17)) xor
               (x(7 downto 0) & x(31 downto 8));
    end function;

    function sigma1(x : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return (x(17 downto 0) & x(31 downto 18)) xor
               (x(18 downto 0) & x(31 downto 19)) xor
               (x(19 downto 0) & x(31 downto 20));
    end function;

begin

    -- Main SHA-256 process
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset internal state
            h <= H0;
            round <= 0;
            processing <= '0';
            done <= '0';
            hash_out <= (others => '0');
        elsif rising_edge(clk) then
            if start = '1' and processing = '0' then
                -- Start SHA-256 computation
                processing <= '1';
                done <= '0';
                round <= 0;

                -- Initialize hash and message schedule
                h <= H0;
                for i in 0 to 15 loop
                    w(i) <= data_in((511 - i*32) downto (480 - i*32));
                end loop;
                for i in 16 to 63 loop
                    w(i) <= sigma1(w(i-2)) + w(i-7) + sigma0(w(i-15)) + w(i-16);
                end loop;
            elsif processing = '1' then
                if round < 64 then
                    -- Perform one round of SHA-256 compression
                    a <= h(0);
                    b <= h(1);
                    c <= h(2);
                    d <= h(3);
                    e <= h(4);
                    f <= h(5);
                    g <= h(6);
                    h_temp <= h(7);

                    h(7) <= g;
                    h(6) <= f;
                    h(5) <= e;
                    h(4) <= d + (h_temp + Sigma1(e) + Ch(e, f, g) + K(round) + w(round));
                    h(3) <= c;
                    h(2) <= b;
                    h(1) <= a;
                    h(0) <= (h_temp + Sigma1(e) + Ch(e, f, g) + K(round) + w(round)) + Sigma0(a) + Maj(a, b, c);

                    round <= round + 1;
                else
                    -- Finalize the hash
                    for i in 0 to 7 loop
                        hash_out((255 - i*32) downto (224 - i*32)) <= h(i);
                    end loop;
                    processing <= '0';
                    done <= '1';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
