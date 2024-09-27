library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM is
  Port ( 
        A: in std_logic_vector(9 downto 0);
        DIN: in std_logic_vector(15 downto 0);
		  DOUT: out std_logic_vector(15 downto 0);
        WR_RD: in std_logic;
        en_RAM: in std_logic;
        clk: in std_logic);
end RAM;

architecture Behavioral of RAM is
    constant ADDR_WIDTH:integer :=6;
    constant DATA_WIDTH:integer :=16;
    
    signal data_out:std_logic_vector (15 downto 0);
    type ram_type is array(0 to 63)
        of std_logic_vector(15 downto 0);
    signal ram: ram_type:=(  "1111111111010101",
									   "0000000000001001",
										"0000000000001001",
										"0000000000001001",
										"0000000000001001",
										"0000000000001001",
										"0000000000001001",
										"0000000000001001",
										"0000000000001001",
										"0000000000001001",
										"0000000000001001",
										"0000000000001001",
										"0000000000001001",
										"0000000000001001",
										"0000000000001001",

                            others=>(others=>'1'));
begin

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if (en_RAM = '1') then
				if ( WR_RD = '1') then 
					ram(conv_integer(a)) <= din;
					dout <= ram(conv_integer(a));	
					else 
						dout <= ram(conv_integer(a));		
				end if;
				
			end if;
		end if;
	end process;
    
end Behavioral;