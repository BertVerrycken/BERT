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

architecture str of BERT is

  constant C_WIN:  natural := G_WIDTH_GPIO_IN;
  constant C_WOUT: natural := G_WIDTH_GPIO_OUT;

  -- -----------------------------------------------
  -- ---- Debouncer                             ----
  -- -----------------------------------------------
  component switchdebounce
    generic(G_MAX_COUNT: natural := 1024;
            G_WIDTH:     natural := C_WIN);
    port (clk:          in  std_logic;
          rst_n:        in  std_logic;
          gpio_in:      in  std_logic_vector(C_WIN-1 downto 0);
          gpio_out:     out std_logic_vector(C_WIN-1 downto 0)
          );
  end component;

  -- -----------------------------------------------
  -- ---- Clock and Reset                       ----
  -- -----------------------------------------------
  component clkrst
  port(clk:             in  std_logic;
       rst_n:           in  std_logic;
       sysclk:          out std_logic;
       sysrst_n:        out std_logic
       );
  end component;

  -- -----------------------------------------------
  -- ---- A4988 control for a stepper motor     ----
  -- -----------------------------------------------
  component motorctrl_a4988
  generic(G_AD_WIDTH: natural := 2;
          G_D_WIDTH:  natural := 32);
  port( -- Clock and Reset --
       clk:             in  std_logic;
       rst_n:           in  std_logic;
       -- AXI Lite
       axils_rsel:      in  boolean;
       axils_wsel:      in  boolean;
       axils_m2s:       in  axil_m2s_t;
       axils_s2m:       out axil_s2m_t;
       -- A4988 stepper driver IC --
       step:            out std_logic;
       dir:             out std_logic
       );
  end component;

  -- -----------------------------------------------
  -- ---- AXI master wrapper                    ----
  -- -----------------------------------------------
  component axim_wrap
  port(clk:             in  std_logic;
       rst_n:           in  std_logic;
       axilm_m2s:       out axil_m2s_t;
       axilm_s2m:       in  axil_s2m_t
       );
  end component;

  -- -----------------------------------------------
  -- ---- AXI arbiter                           ----
  -- -----------------------------------------------
  component axi_arbiter
  port( -- Clock and Reset --
        clk:            in  std_logic;
        rst_n:          in  std_logic;
        -- AXI Lite master interface
        axilm_m2s:      in  axil_m2s_t;
        axilm_s2m:      out axil_s2m_t;
        -- AXI Lite slave interfaces
        axils_rsel:     out boolean;
        axils_wsel:     out boolean;
        axils_m2s:      out axil_m2s_t;
        axils_s2m:      in  axil_s2m_t
        );
  end component;

  -- -----------------------------------------------
  -- ---- Local architecture definitions        ----
  -- -----------------------------------------------
  signal sysrst_n:      std_logic;
  signal sysclk:        std_logic;
  signal gpio_in_clean: std_logic_vector(C_WIN-1 downto 0);
  signal axils_rsel:    boolean;
  signal axils_wsel:    boolean;
  -- Master to arbiter
  signal axilm_m2s:     axil_m2s_t;
  signal axilm_s2m:     axil_s2m_t;
  -- Arbiter to slave
  signal axils_m2s:     axil_m2s_t;
  signal axils_s2m:     axil_s2m_t;

begin

  -- ===============================================
  -- ==== Debouncer                             ====
  -- ===============================================
  -- Debounce the gpio_in in case they are buttons
  --
  i_switchdebounce: switchdebounce
  port map(clk          => sysclk,
           rst_n        => sysrst_n,
           gpio_in      => gpio_in,
           gpio_out     => gpio_in_clean
           );

  -- ===============================================
  -- ==== Clock and Reset                       ====
  -- ===============================================
  -- Every digital circuit has a clock and reset unit, especially in case
  -- the reset is external to the chip, we need to make sure the reset
  -- is entered as soon as the pin goes active low, all outputs go to safe
  -- state immediately. The reset exit must be synchronous to the clock,
  -- to make sure all flip-flops on that clock exit reset state at the
  -- same moment in time.
  --
  i_clkrst:clkrst
  port map(clk          => clk,         -- Clock pin
           rst_n        => rst_n,       -- Reset pin
           sysclk       => sysclk,      -- System clock
           sysrst_n     => sysrst_n     -- Async reset, synchronous to sysclk
           );

  -- ===============================================
  -- ==== Motor control via external A4988 IC   ====
  -- ===============================================
  --
  i_motorctrl_a4988: motorctrl_a4988
  port map(clk          => sysclk,
           rst_n        => sysrst_n,
           axils_rsel   => axils_rsel,
           axils_wsel   => axils_wsel,
           axils_m2s    => axils_m2s,
           axils_s2m    => axils_s2m,
           step         => gpio_out(0),
           dir          => gpio_out(1)
           );

  -- ===============================================
  -- ==== AXI master wrapper                    ====
  -- ===============================================
  --
  i_axim_wrap: axim_wrap
  port map(clk          => sysclk,
           rst_n        => sysrst_n,
           axilm_m2s    => axilm_m2s,
           axilm_s2m    => axilm_s2m
           );

  -- ===============================================
  -- ==== AXI arbiter                           ====
  -- ===============================================
  -- The arbiter generates the select signals for read and write to the slaves
  --
  i_axi_arbiter: axi_arbiter
  port map(clk          => sysclk,
           rst_n        => sysrst_n,
           axilm_m2s    => axilm_m2s,
           axilm_s2m    => axilm_s2m,
           axils_rsel   => axils_rsel,
           axils_wsel   => axils_wsel,
           axils_m2s    => axils_m2s,
           axils_s2m    => axils_s2m
           );

end architecture;
