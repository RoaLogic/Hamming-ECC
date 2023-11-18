////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.         //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.   //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--'   //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  |\ `--.   //
//   `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---'   //
//                                             `---'              //
//                                                                //
//      Hamming Encoder / Decoder Testbench                       //
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

module testbench_top;
  parameter K           = 72;  //Limitation $urandom is a 32bit number
  parameter P0_LSB      = 0;
  parameter DEC_LATENCY = 0;
  parameter RUNS        = 100_000;


  //-------------------------------------------------------
  // Functions
  function integer calculate_m;
    input integer k;

    integer m;
  begin
    m=1;
    while (2**m < m+k+1) m++;

    calculate_m = m;
  end
  endfunction //calculate_m


  //-------------------------------------------------------
  //
  // Variables
  //
  localparam int m = calculate_m(K);
  localparam int n = m + K;

  logic clk, rst_n;

  logic [K-1:0] enc_d,
                ch_enc_d,
                dec_q;
  logic [n  :0] enc_q,
                ch_q;
  logic         dec_sb_err,
                dec_db_err,
                dec_sb_fix;

  int           nflips, ch_nflips,
                flip1,  ch_flip1,
                flip2,  ch_flip2;


  //-------------------------------------------------------
  //
  // Tasks
  //

  task welcome_msg();
    $display("\n\n");
    $display ("------------------------------------------------------------");
    $display (" ,------.                    ,--.                ,--.       ");
    $display (" |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---. ");
    $display (" |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--' ");
    $display (" |  |\\  \\ ' '-' '\\ '-'  |    |  '--.' '-' ' '-' ||  |\\ `--. ");
    $display (" `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---' ");
    $display ("- Hamming ECC Encoder/Decoder Testbench--  `---'  ----------");
    $display ("-------------------------------------------------------------");
    $display ("  K       = %0d", K);
    $display ("  m       = %0d", m);
    $display ("  n       = %0d", n);
    $display ("  cw_bits = %0d", n+1);
    $display ("  P0      = %0d", P0_LSB ? 0 : n);
    $display ("-------------------------------------------------------------");
    $display ("\n");
  endtask

  task goodbye_msg();
    $display("\n\n");
    $display ("------------------------------------------------------------");
    $display (" ,------.                    ,--.                ,--.       ");
    $display (" |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---. ");
    $display (" |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--' ");
    $display (" |  |\\  \\ ' '-' '\\ '-'  |    |  '--.' '-' ' '-' ||  |\\ `--. ");
    $display (" `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---' ");
    $display ("- Hamming ECC Encoder/Decoder Testbench--  `---'  ----------");
    $display ("-------------------------------------------------------------");
    $display ("  Regression test complete");
    $display ("  Status = %s", checker_inst.ugly ? "FAILED" : "PASSED");
    $display ("-------------------------------------------------------------");
  endtask


  task tst_done();
    //wait for data to propagate pipeline
    nflips = 0;
    repeat (5) @(posedge clk);

    //Display test results
    $display ("Test done. Checks good=%0d. Checks bad=%0d. Checks ugly=%0d", checker_inst.good, checker_inst.bad, checker_inst.ugly);
  endtask

  task rst_errors();
    checker_inst.reset_counters();
  endtask

  task tst_clean_seq (input int runs);
    //basic test, no bit flips
    $display("--------------------");
    $display("- Running clean_seq (%0d runs)", runs);
    $display("--------------------");

    rst_errors();
    nflips = 0;

    for (enc_d = 0; enc_d < runs; enc_d++)
    begin
	@(posedge clk);
    end

    tst_done();
  endtask


  task tst_clean_rnd (input int runs);
    //basic test, no bit flips
    $display("--------------------");
    $display("- Running clean_rnd (%0d runs)", runs);
    $display("--------------------");

    rst_errors();
    nflips = 0;

    repeat (runs)
    begin
        enc_d = $random();
	@(posedge clk);
    end

    tst_done();
  endtask


  task tst_1bflip_seq (input int runs);
    //single bit flip
    $display("--------------------");
    $display("- Running 1bflip_seq (%0d runs)", runs);
    $display("--------------------");

    rst_errors();
    nflips = 1;

    for (flip1 = 0; flip1 <= runs; flip1++)
    begin
        enc_d = $random();
	@(posedge clk);
    end

    tst_done();
  endtask


  task tst_1bflip_rnd (input int runs, input int maxrange);
    //single bit flip
    $display("--------------------");
    $display("- Running 1bflip_rnd (%0d runs)", runs);
    $display("--------------------");

    rst_errors();
    nflips = 1;

    repeat (runs)
    begin
        flip1 = $urandom_range(maxrange);
        enc_d = $random();
	@(posedge clk);
    end

    tst_done();
  endtask


  task tst_2bflip_seq (input int runs);
    //single bit flip
    $display("--------------------");
    $display("- Running 2bflip_seq (%0d runs)", runs);
    $display("--------------------");

    rst_errors();
    nflips = 2;

    for (flip1 = 0; flip1 < runs  ; flip1++)
    for (flip2 = 0; flip2 < runs-1; flip2++)
    begin
        if (flip2==flip1) flip2++;
	
        enc_d = $random();
	@(posedge clk);
    end

    tst_done();
  endtask


  task tst_2bflip_rnd (input int runs, input int maxrange);
    //single bit flip
    $display("--------------------");
    $display("- Running 2bflip_rnd (%0d runs)", runs);
    $display("--------------------");

    rst_errors();
    nflips = 2;

    repeat (runs)
    begin
        flip1 = $urandom_range(maxrange);
	flip2 = $urandom_range(maxrange-1);

	if (flip2==flip1) flip2++;

        enc_d = $random();
	@(posedge clk);
    end

    tst_done();
  endtask
  

  task tst_rnd (input int runs, input int maxrange);
    //single bit flip
    $display("--------------------");
    $display("- Running rnd (%0d runs)", runs);
    $display("--------------------");

    rst_errors();
    nflips = 2;

    repeat (runs)
    begin
        nflips = $urandom_range(2);
        flip1  = $urandom_range(maxrange);
	flip2  = $urandom_range(maxrange-1);

	if (flip2==flip1) flip2++;

        enc_d = $random();
	@(posedge clk);
    end

    tst_done();
  endtask


  //-------------------------------------------------------
  //
  // Testbench Body
  //

  //generate clock
  always #10 clk = ~clk;


  //testvector generator


  //instantiate encoder
  ecc_enc #(
    .K      ( K      ),
    .P0_LSB ( P0_LSB ) )
  dut_enc (
    .d_i  ( enc_d ),      //information bit vector input
    .q_o  ( enc_q ),      //encoded data word output

    .p_o  (       ),      //parity vector output
    .p0_o (       ));     //extended parity bit


  //instantiate channel
  ecc_tb_channel #(n)
  channel_inst (
    .clk_i    ( clk       ),

    .nflips_i ( nflips    ),
    .nflips_o ( ch_nflips ),

    .flip1_i  ( flip1     ),
    .flip2_i  ( flip2     ),
    .flip1_o  ( ch_flip1  ),
    .flip2_o  ( ch_flip2  ),

    .d_i      ( enc_q     ),
    .q_o      ( ch_q      ));


  //delay data; same delay as channel
  always @(posedge clk) ch_enc_d <= enc_d;


  //instantiate decoder
  ecc_dec #(
    .K          ( K           ),
    .P0_LSB     ( P0_LSB      ),
    .LATENCY    ( DEC_LATENCY ))
  dut_dec (
    .rst_ni     ( rst_n      ),   //asynchronous reset
    .clk_i      ( clk        ),   //clock input
    .clkena_i   ( 1'b1       ),   //clock enable input

    //data ports
    .d_i        ( ch_q       ),   //encoded code word input
    .q_o        ( dec_q      ),   //information bit vector output
    .syndrome_o (            ),   //syndrome vector output

    //flags
    .sb_err_o   ( dec_sb_err ),   //single bit error detected
    .db_err_o   ( dec_db_err ),   //double bit error detected
    .sb_fix_o   ( dec_sb_fix ));  //repaired error in the information bits


  //instantiate checker
  ecc_tb_checker #(
    .K        ( K      ),
    .P0_LSB   ( P0_LSB ))
  checker_inst (
    .clk_i    ( clk        ),

    .nflips_i ( ch_nflips  ),
    .flip1_i  ( ch_flip1   ),
    .flip2_i  ( ch_flip2   ),

    .enc_d_i  ( ch_enc_d   ),
    .dec_q_i  ( dec_q      ),

    .sb_err_i ( dec_sb_err ),
    .db_err_i ( dec_db_err ),
    .sb_fix_i ( dec_sb_fix ));


  //Tests
  initial
  begin
      clk   = 0;

      rst_n = 0;
      repeat (5) @(posedge clk);
      rst_n = 1;

      welcome_msg();
      tst_clean_seq(K);
      tst_clean_rnd(RUNS);
      tst_1bflip_seq(n);
      tst_1bflip_rnd(RUNS, n);
      tst_2bflip_seq(n+1);
      tst_2bflip_rnd(RUNS, n);
      tst_rnd(RUNS,n);
      goodbye_msg();
      
      $finish();
  end


endmodule : testbench_top
