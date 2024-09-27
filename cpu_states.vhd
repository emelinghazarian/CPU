----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:47:59 05/28/2023 
-- Design Name: 
-- Module Name:    cpu_states - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use ieee.numeric_std.all;


entity cpu_states is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  out1:out std_logic_vector(15 downto 0));
end cpu_states;

architecture Behavioral of cpu_states is

signal WR_status:std_logic ;
signal E,T1 :std_logic ;
signal X,Y: std_logic;
signal T: std_logic_vector(11 downto 0);
signal R: std_logic_vector(7 downto 0);
signal AC_OUT: std_logic_vector(15 downto 0);
signal MARO: std_logic_vector(5 downto 0);
signal MDR: std_logic_vector(15 downto 0):=(others=>'0');
signal MAR: std_logic_vector(5 downto 0);
signal PC: std_logic_vector(9 downto 0);
signal AC,AC_tmp2: std_logic_vector(15 downto 0) := (others=>'0');
signal DR: std_logic_vector(15 downto 0);
signal IR: std_logic_vector(15 downto 0);
signal B,B2,J,ac_tmp,temp_d: std_logic_vector(15 downto 0);
signal op_code: std_logic_vector(5 downto 0);
signal addr: std_logic_vector(9 downto 0);
signal sig_en_rom ,WR_RD,en_RAM: std_logic;
type state_st is (reset_pc,fetch,decode,wait_st,exe_wait,RAM_FLG,state_read,state_exe);

signal state: state_st;
	COMPONENT ROM
	PORT(
		A : IN std_logic_vector(9 downto 0);
		en_ROM : IN std_logic;          
		D : OUT std_logic_vector(15 downto 0);
		clk:in std_logic
		);
	END COMPONENT;
	
		COMPONENT RAM
	PORT(
		A : IN std_logic_vector(9 downto 0);
		WR_RD : IN std_logic;
		en_RAM : IN std_logic;
		clk : IN std_logic;       
		DIN : IN std_logic_vector(15 downto 0);
		DOUT : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
component multi6x6 is
    Port ( a6 : in  STD_LOGIC_VECTOR (5 downto 0);
           b6 : in  STD_LOGIC_VECTOR (5 downto 0);
           p : out  STD_LOGIC_VECTOR (11 downto 0));
end component;

component final is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           q : out  STD_LOGIC_VECTOR (7 downto 0));
end component;


begin

MAR <= "000000";
			sig_en_rom <= '1';
          q1: multi6x6 port map 
			 ( a6 =>STD_LOGIC_VECTOR (AC(5 downto 0)),
            b6 =>STD_LOGIC_VECTOR (temp_d(5 downto 0)),
            p  =>T );
					 
          q2: final port map 
            ( A => temp_d,
                 q => R );			 
					  
	      Inst_ROM: ROM PORT MAP(
	    	A => PC ,
	    	D => IR,
		   en_ROM => sig_en_rom ,
		   clk => clk
	      );
	      Inst_RAM: RAM PORT MAP(
		   A => addr,
		   DIN =>AC,
		   DOUT => temp_d,
		   WR_RD =>WR_RD ,
		   en_RAM =>en_RAM  ,
		   clk =>clk 
	      );


 process(clk,reset)
 
    begin 
        if(reset='1')then
            state<=reset_pc;
        elsif(clk'event and clk='1') then
            case state is
                when reset_pc=>
                    PC<=(others=>'0');
                    AC<=(others=>'0');
						  b<="0000000000000000";
						  E <='0';
						  ac_tmp <= "0000000000000000";
						  addr <= pc;
                  state<=fetch;
						  
                when fetch=>
						  T1<=E;	 
                    addr <= pc;
					     ac_tmp <= ac;
                    PC<=PC+1;
						  if (op_code = "000001" or op_code ="000010" 
						  or op_code ="000011"or op_code ="000100" or 
						  op_code ="010000" or op_code ="100000") then
						  ac <= ac_tmp2; 
                    end if;
						  state <= decode;
						  
						

               when decode=>
                    op_code<=IR(15 downto 10);
						  addr<= ir(9 downto 0);
						  if (op_code = "000001" or op_code ="000010" 
						  or op_code ="000011"or op_code ="000100" or 
						  op_code ="010000" or op_code ="100000") then
						  en_RAM <= '1';
						  state<=state_exe;
						  else 
						  en_RAM <= '0';
						  state<=state_exe; 
						  end if;
						  
						 when state_exe =>
						  
						  case op_code is
						  
                        --and 						  
                        when "000001"=>
							    ac_tmp2 <= AC and temp_d;
								 
								 addr<= ir(9 downto 0);

                        --store
				         	when "000010"=>
                         ac<=temp_d;
								 WR_RD <= '1';
								 addr<= ir(9 downto 0);
								 
								 
								--load	 
                        when "000011"=>
                         ac_tmp2 <= temp_d;
								 addr<= ir(9 downto 0);
									 
								--add	 
							   when "000100"=>
								 DR <= temp_d; 
								 AC_tmp2 <= std_logic_vector(unsigned(AC)+unsigned(temp_d));
								 E <= AC(15);
								 addr<= ir(9 downto 0);
								 
								--increment ac	 
								when "000101"=>
								 AC <= AC+'1';
								-- state <= fetch;
								
								--clear ac
								when "000110"=>
                         AC <= "0000000000000000";
								 
								--clear e	 
								when "000111"=>
								 E <= '0';
								 
								--circular left shift			
								when "001000"=>
									AC(15 downto 1) <= ac_tmp(14 downto 0) ;
									E <= ac_tmp(15) ;
									AC(0) <= T1 ;
								--	 state<= fetch ;
								
                        --circular right shift
								when "001001"=>
									E <= ac_tmp(0) ;
									AC(14 downto 0) <= ac_tmp(15 downto 1) ;
									AC(15) <= T1 ;
									--state<= fetch ;

                        --spa
								when "001010"=>
                             if (AC>0) then
						             PC <= PC+1;
						               end if;
											
								--sna	 
								when "001011"=>
                             if (AC<0) then
					                 PC <= PC+1;
            						  end if;
										  
								--sze	 
								when "001100"=>
                             if (E='0') then
		         				  PC<=PC+1;
          						  end if;
									  
								--sza	 
								when "001101"=>
                             if (AC="0000000000000000") then
				         		  PC<=PC+1;
           						  end if;
									  
								--linear left shift	 
								when "001110"=>
									 AC(15 downto 1)<=AC(14 downto 0);
									 AC(0)<='0';

                        --linear right shift									 
								when "001111"=>
									 AC(14 downto 0)<=AC(15 downto 1);
									 AC(15)<='0';
									 
								--multiply	 
								when "010000"=>
								DR <= temp_d;
                             AC_tmp2<="0000"&T;

									  addr<= ir(9 downto 0);
									  
								--sqr	 
								when "100000"=>
								DR <= temp_d;
                            AC_tmp2<="00000000"&R(7 downto 0);		
									 addr<= ir(9 downto 0);
									 
							   when others =>
                            state<=fetch;


end case;

out1 <= AC; 
state<= fetch ;
             

when others =>
		state<=fetch;
end case;
 --state <= fetch ;
end if; 
end process;

               	             

end Behavioral;

