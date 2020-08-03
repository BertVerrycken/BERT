--MIT License
--
-- Copyright (c) 2020, Bert Verrycken, bertv@verrycken.com
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- AXI Lite package
use work.axil_pkg.all;
use work.axi_pkg.axi_response_ok;
use work.axi_pkg.axi_response_decerr;

architecture rtl of axim_wrap is
  type T_AXIM_FSM is    (E_IDLE, E_ADDR, E_DATA);
  signal start_stop_z1: boolean;
  signal motor_on:      boolean;
begin

  process_aximaster: process(clk, rst_n)
    variable axim_fsm:  T_AXIM_FSM;
  begin
    if (rst_n = '0') then
      axilm_m2s         <= axil_m2s_init;
      start_stop_z1     <= false;
      motor_on          <= FALSE;
      axim_fsm          := E_IDLE;
    elsif (rising_edge(clk)) then
      start_stop_z1     <= start_stop;
      axilm_m2s         <= axil_m2s_init;
      -- Avoid seperate flipflop
      case axim_fsm is
        when E_IDLE =>
          -- Rising edge = button pressed
          if (start_stop /= start_stop_z1) then
            axim_fsm    := E_ADDR;
          end if;
        when E_ADDR =>
          axilm_m2s.aw.valid <= '1';
          axilm_m2s.aw.addr  <= (others => '0');
          if (axilm_s2m.aw.ready = '1') then
            axim_fsm   := E_DATA;
          end if;
        when E_DATA =>
          axilm_m2s.w.valid  <= '1';
          if not(motor_on) then
            axilm_m2s.w.data   <= (0 => '1', others => '0'); -- Enable bit
            motor_on    <= true;
          else
            axilm_m2s.w.data   <= (others => '0'); -- Disable bit
            motor_on    <= false;
          end if;
          if ((axilm_s2m.b.resp = axi_response_ok) and
              (axilm_s2m.b.valid = '1') and
              (axilm_s2m.w.ready = '1')) then
            axilm_m2s.b.ready <= '1';
            axim_fsm    := E_IDLE;
          end if;
      end case;
    end if;
  end process;

end architecture;
