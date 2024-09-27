library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity Decoder is
  Port ( 
        A6:in std_logic;
        A5:in std_logic;
        en_ROM:out std_logic;
        en_RAM:out std_logic;
        en_Statemachine:out std_logic     
        );
end Decoder;

architecture GateDesign of Decoder is
signal x:std_logic_vector(1 downto 0);

begin
x<= A6 & A5;
    process(x)
        begin
        en_ROM<='0';
        en_RAM<='0';
        en_Statemachine<='0';
        case x is
            when "00" | "01"=>
                en_ROM<='1';
            when  "10"=>
                en_RAM<='1';
            when "11"=>
                en_Statemachine<='1';

            when others=>
        
        end case;
    end process;

end GateDesign;