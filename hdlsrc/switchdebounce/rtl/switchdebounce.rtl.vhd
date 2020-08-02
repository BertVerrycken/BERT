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

architecture rtl of switchdebounce is

  -- Use the generic as a local (static) constant (VHDL quirk)
  constant C_MAX_COUNT: natural := G_MAX_COUNT;

  -- Double synchronizer for the input vector
  signal gpio_in_z1: std_logic_vector(G_WIDTH-1 downto 0);
  signal gpio_in_z2: std_logic_vector(G_WIDTH-1 downto 0);

begin

process_debounce: process(clk, rst_n)
  subtype t_cnt is natural range 0 to C_MAX_COUNT-1;
  type t_cnt_array is array(g_width-1 downto 0) of natural;
  variable cnt_array: t_cnt_array;
begin
  if (rst_n = '0') then
    gpio_in_z1                  <= (others => '0');
    gpio_in_z2                  <= (others => '0');
    gpio_out                    <= (others => '0');
    for index in 0 to (G_WIDTH - 1) loop
      cnt_array(index)          := 0;
    end loop;
  elsif (rising_edge(clk)) then
    -- Double flip-flop synchronizer
    gpio_in_z1                  <= gpio_in;
    gpio_in_z2                  <= gpio_in_z1;
    -- Loop over all inputs
    for index in 0 to (G_WIDTH - 1) loop
      if (gpio_in_z1(index) = gpio_in_z2(index)) then
        -- If the input is stable for the defined period of time
        -- latch the new value, if not max count value yet,
        -- keep counting
        if (cnt_array(index) = C_MAX_COUNT-1) then
          gpio_out(index)       <= gpio_in_z2(index);
        else
          cnt_array(index)      := cnt_array(index)+1;
        end if;
      else
        -- If the two synchronizer values differ, reset counter
        cnt_array(index)        := 0;
      end if;
    end loop;
  end if;
end process;

end architecture;
