-- uart.vhd: UART controller - receiving part
-- Author(s): Matus Durica xduric06
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
    CLK: 	    in std_logic;
	  RST: 	    in std_logic;
	  DIN: 	    in std_logic;
	  DOUT: 	    out std_logic_vector(7 downto 0);
    DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
  signal midbit_cnt : std_logic_vector(4 downto 0):= "00001";
  signal startcnfrm_cnt : std_logic_vector(3 downto 0):= "0000";
  signal bit_cnt : std_logic_vector(3 downto 0):= "0000";
  signal startcnfrm_cnt_en : std_logic := '0';
  signal midbit_cnt_en : std_logic := '0';
  signal bit_cnt_en : std_logic := '0';
  signal vld_out : std_logic := '0';
begin
  -- mapping entities
  FSM:entity work.UART_FSM(behavioral)
    port map (
      CLK => CLK,
      RST => RST,
      DIN => DIN,
      MIDBIT_CNT => midbit_cnt,
      STARTCNFRM_CNT => startcnfrm_cnt,
      BIT_CNT => bit_cnt,
      STARTCNFRM_CNT_ENABLE => startcnfrm_cnt_en,
      MIDBIT_CNT_ENABLE => midbit_cnt_en,
      BIT_CNT_ENABLE => bit_cnt_en,
      VLD_OUT => vld_out
    );
    
    process(CLK) begin
      if rising_edge(CLK) then
        -- setting default DOUT_VLD value
        DOUT_VLD <= '0';
        -- setting default DOUT value
        if rst = '1' then
          DOUT <= "00000000";
        end if;
        -- counting to midbit of data bits
        if midbit_cnt_en = '1' then
          midbit_cnt <= midbit_cnt + '1';
        else
          midbit_cnt <= "00001";
        end if;
        -- counting to midbit of startbit
        if startcnfrm_cnt_en = '1' then
          startcnfrm_cnt <= startcnfrm_cnt + '1';
        else
          startcnfrm_cnt <= "0000";
        end if;
        -- writing 1 to DOUT_VLD when validated
        if vld_out = '1' then
          DOUT_VLD <= '1';
        end if;
        -- all bits were read 
        if bit_cnt = "1000" then
          bit_cnt <= "0000";
        end if;
        -- writing when at midbit
        if midbit_cnt = "10000" then
          -- reseting midbit counter
          midbit_cnt <= "00001";
          -- writing to output
          case bit_cnt is
            when "0000" => DOUT(0) <= DIN;
            when "0001" => DOUT(1) <= DIN;
            when "0010" => DOUT(2) <= DIN;
            when "0011" => DOUT(3) <= DIN;
            when "0100" => DOUT(4) <= DIN;
            when "0101" => DOUT(5) <= DIN;
            when "0110" => DOUT(6) <= DIN;
            when "0111" => DOUT(7) <= DIN;
            when others => null;
          end case;
          -- incrementing counter of data bits
          if bit_cnt_en = '1' then
            bit_cnt <= bit_cnt + '1';
          end if;        
      end if;
    end if;
  end process;
end behavioral;
