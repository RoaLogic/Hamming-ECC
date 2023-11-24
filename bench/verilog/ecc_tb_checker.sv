////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.         //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.   //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--'   //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  |\ `--.   //
//   `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---'   //
//                                             `---'              //
//                                                                //
//      Hamming Encoder / Decoder Testbench - Checker             //
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
module ecc_tb_checker #(
  parameter K = 8,
  parameter P0_LSB = 0
)
(
  input          clk_i,

  input  int     nflips_i,
  input  int     flip1_i,
  input  int     flip2_i,

  input  [K-1:0] enc_d_i,
  input  [K-1:0] dec_q_i,

  input          sb_err_i,
                 db_err_i,
                 sb_fix_i
);

  //---------------------------------------------------------
  // Tasks
  //---------------------------------------------------------
  int good, bad, ugly;

  task reset_counters();
    good = 0;
    bad  = 0;
  endtask


  //---------------------------------------------------------
  // Functions
  //---------------------------------------------------------
  function integer calculate_m;
    input integer k;

    integer m;
  begin
    m=1;
    while (2**m < m+k+1) m++;

    calculate_m = m;
  end
  endfunction //calculate_m


  function is_power_of_2(input int n);
    is_power_of_2 = (n & (n-1)) == 0;
  endfunction


  //-------------------------------------------------------
  // Constants
  //
  localparam int m = calculate_m(K);
  localparam int n = m + K;

  localparam P0_LOCATION = (P0_LSB == 0) ? n : 0;
  

  //-------------------------------------------------------
  // Module body

  initial
  begin
      good = 0; //correct
      bad  = 0; //test errors
      ugly = 0; //total errors
  end

  always @(negedge clk_i)
  begin
      //Check if enc_d == dec_q
      if (enc_d_i !== dec_q_i && !db_err_i)
      begin
          bad++; ugly++;
          $display ("Data mismatch, expected %0h, received %0h", enc_d_i, dec_q_i);
      end
      else good++;

      //Check flags
      case (nflips_i)
        0: begin
               //no flags should be asserted
               if (sb_err_i)
               begin
                   $display ("sb_err asserted: WRONG");
                   bad++; ugly++;
               end
               else good++;

               if (db_err_i)
               begin
                   $display ("db_err asserted: WRONG");
                   bad++; ugly++;
               end
               else good++;

               if (sb_fix_i)
               begin
                   $display ("sb_fix asserted: WRONG");
                   bad++; ugly++;
               end
               else good++;
           end

        1: begin
               //sb_err should be asserted, except for P0 
	       if (flip1_i == P0_LOCATION)
               begin
                    if ( sb_err_i)
                    begin
                        $display ("sb_err asserted on P0 bit flip: WRONG (flipped bit%0d)", flip1_i);
                        bad++; ugly++;
                    end
                    else
                    begin
//                        $display ("sb_err not asserted on P0 bit flip: GOOD");
                        good++;
                    end
               end
               else if (!sb_err_i)
               begin
                   $display  ("sb_err not asserted: WRONG (flipped bit%0d)", flip1_i);
                   bad++; ugly++;
               end
               else good++;


	       //db_err should never be asserted
               if (db_err_i)
               begin
                   $display ("db_err asserted: WRONG (flipped bit %0d)", flip1_i);
                   bad++; ugly++;
               end
               else good++;

               //parity bits are on power of 2, should never assert sb_fix
	       if (sb_fix_i)
               begin
                   if (is_power_of_2( P0_LSB ? flip1_i : flip1_i +1 ))
                   begin
                       $display ("sb_fix asserted on parity bit (flipped bit%0d): WRONG", flip1_i);
                       bad++; ugly++;
                   end
                   else good++;
               end
               else
               begin

                   if (!is_power_of_2( P0_LSB ? flip1_i : flip1_i +1 ) && (flip1_i != P0_LOCATION))
                   begin
                       $display ("sb_fix not asserted on data bit (flipped bit%0d): WRONG", flip1_i);
                       bad++; ugly++;
                   end
                   else good++;
               end
           end

        2: begin
                //db_err should be asserted
                if (!db_err_i)
                begin
                    $display ("db_err not asserted: WRONG (flipped bits%0d and %0d", flip1_i, flip2_i);
                    bad++; ugly++;
                end
                else good++;
		
                //sb_err should not be asserted
 		if (sb_err_i)
                begin
                    $display ("sb_err asserted AND db_err not asserted: WRONG (flipped bits%0d and %0d)", flip1_i, flip2_i);
                    bad++; ugly++;
                end
                else good++;

                //sb_fix should not be asserted
                if (sb_fix_i)
                begin
                    $display ("sb_fix asserted AND db_err not asserted: WRONG(flipped bits%0d and %0d)", flip1_i, flip2_i);
                    bad++; ugly++;
                end
                else good++;
           end
      endcase
  end

endmodule

