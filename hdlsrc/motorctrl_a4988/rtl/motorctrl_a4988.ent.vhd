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

entity motorctrl_a4988 is
  generic(G_AD_WIDTH: natural := 2;
          G_D_WIDTH:  natural := 32);
port(   -- Clock and Reset --
        clk:            in  std_logic;
        rst_n:          in  std_logic;
        -- AXI Lite
        axils_rsel:     in  boolean;
        axils_wsel:     in  boolean;
        axils_m2s:      in  axil_m2s_t;
        axils_s2m:      out axil_s2m_t := axil_s2m_init;
        -- A4988 stepper driver IC --
        motor_active:   out std_logic;
        step:           out std_logic;
        dir:            out std_logic
    );
end entity;
