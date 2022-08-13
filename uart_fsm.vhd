-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): Matus Durica xduric06
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK : in std_logic;
   RST : in std_logic;
   DIN : in std_logic;
   MIDBIT_CNT : in std_logic_vector(4 downto 0); --counter for counting to midbits of data bits
   STARTCNFRM_CNT : in std_logic_vector(3 downto 0); --counter which counts to midbit of startbit to confirm its value
   BIT_CNT : in std_logic_vector(3 downto 0); --counter for the amount of data bits
   STARTCNFRM_CNT_ENABLE : out std_logic; --mealy output
   MIDBIT_CNT_ENABLE : out std_logic; --moore output
   BIT_CNT_ENABLE : out std_logic; --moore output
   VLD_OUT : out std_logic --moore output
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type STATES is (WAIT_STATE, START_STATE, READ_STATE, STOP_STATE, VALID_STATE);
signal state : STATES := WAIT_STATE;
begin
  
  VLD_OUT <= '1' when state = VALID_STATE 
  else '0';
    
  STARTCNFRM_CNT_ENABLE <= '1' when state = WAIT_STATE and DIN = '0' 
  else '0';
  
  MIDBIT_CNT_ENABLE <= '1' when state = START_STATE or state = READ_STATE 
  else '0';
  
  BIT_CNT_ENABLE <= '1' when state = START_STATE or state = READ_STATE 
  else '0';
    
process (CLK) begin
  if rising_edge(CLK) then
    if RST = '1' then
        state <= WAIT_STATE;
    else
      case state is
        
        when WAIT_STATE => if DIN = '0' and STARTCNFRM_CNT = "1000" then
          state <= START_STATE;
        end if;
        
        when START_STATE => if MIDBIT_CNT = "10000" then
          state <= READ_STATE;
        end if;
        
        when READ_STATE => if BIT_CNT = "1000" then
          state <= STOP_STATE;
        end if;
        
        when STOP_STATE => if DIN = '1' then
          state <= VALID_STATE;
        end if;
        
        when VALID_STATE => state <= WAIT_STATE;
          
        when others => null;
          
      end case;
    end if;
  end if;
end process;
end behavioral;

