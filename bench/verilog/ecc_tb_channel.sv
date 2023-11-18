////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.         //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.   //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--'   //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  |\ `--.   //
//   `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---'   //
//                                             `---'              //
//                                                                //
//      Hamming Encoder / Decoder Testbench - Dirty Channel       //
//                                                                //
////////////////////////////////////////////////////////////////////
//                                                                //
//     Copyright (C) 2023 ROA Logic BV                            //
//     www.roalogic.com                                           //
//                                                                //
//     This source file may be used and distributed without       //
//   restrictions, provided that this copyright statement is      //
//   not removed from the file and that any derivative work       //
//   contains the original copyright notice and the associated    //
//   disclaimer.                                                  //
//                                                                //
//     This soure file is free software; you can redistribute     //
//   it and/or modify it under the terms of the GNU General       //
//   Public License as published by the Free Software             //
//   Foundation, either version 3 of the License, or (at your     //
//   option) any later versions.                                  //
//   The current text of the License can be found at:             //
//   http://www.gnu.org/licenses/gpl.html                         //
//                                                                //
//     This source file is distributed in the hope that it will   //
//   be useful, but WITHOUT ANY WARRANTY; without even the        //
//   implied warranty of MERCHANTABILITY or FITTNESS FOR A        //
//   PARTICULAR PURPOSE. See the GNU General Public License for   //
//   more details.                                                //
//                                                                //
////////////////////////////////////////////////////////////////////


/*
 * Receive codeword and corrupt either 1 or 2 random bits
 */
module ecc_tb_channel #(
  parameter n = 8
)
(
  input            clk_i,

  input  int       nflips_i,
  output int       nflips_o,

  input  int       flip1_i,
  input  int       flip2_i,
  output int       flip1_o,
  output int       flip2_o,

  input      [n:0] d_i,
  output reg [n:0] q_o
);

  //-------------------------------------------------------
  // Variables
  //
  logic [n:0] cw;


  //-------------------------------------------------------
  // Module body

  always @(posedge clk_i)
  begin
      nflips_o <= nflips_i;
      flip1_o  <= flip1_i;
      flip2_o  <= flip2_i;
  end


  always @(posedge clk_i)
  begin
      q_o <= d_i;
      if (nflips_i > 0) q_o[flip1_i] <= ~d_i[flip1_i];
      if (nflips_i > 1) q_o[flip2_i] <= ~d_i[flip2_i];
  end

endmodule

