/////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.          //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.    //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--'    //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  |\ `--.    //
//   `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---'    //
//                                             `---'               //
//   Error Correction and Detection Decoder                        //
//   Parameterized Extended Hamming Code Decoder                   //
//                                                                 //
/////////////////////////////////////////////////////////////////////
//                                                                 //
//             Copyright (C) 2017 ROA Logic BV                     //
//             www.roalogic.com                                    //
//                                                                 //
//   This source file may be used and distributed without          //
//   restriction provided that this copyright statement is not     //
//   removed from the file and that any derivative work contains   //
//   the original copyright notice and the associated disclaimer.  //
//                                                                 //
//      THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY        //
//   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED     //
//   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS     //
//   FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR OR     //
//   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,  //
//   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT  //
//   NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;  //
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)      //
//   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN     //
//   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR  //
//   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS          //
//   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  //
//                                                                 //
/////////////////////////////////////////////////////////////////////

// +FHDR -  Semiconductor Reuse Standard File Header Section  -------
// FILE NAME      : ecc_dec.sv
// DEPARTMENT     :
// AUTHOR         : rherveille
// AUTHOR'S EMAIL :
// ------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE        AUTHOR      DESCRIPTION
// 1.0     2017-04-07  rherveille  initial release
// ------------------------------------------------------------------
// KEYWORDS : HAMMING ERROR CORRECTION DECODER                 
// ------------------------------------------------------------------
// PURPOSE  : Decodes Data and ECC bits from incoming data
//            Detects and corrects bit errors
// ------------------------------------------------------------------
// PARAMETERS
//  PARAM NAME        RANGE  DESCRIPTION              DEFAULT UNITS
//  K                 1+     Information Vector Size  8
// ------------------------------------------------------------------
// REUSE ISSUES 
//   Reset Strategy      : none
//   Clock Domains       : none
//   Critical Timing     :
//   Test Features       : na
//   Asynchronous I/F    : yes
//   Scan Methodology    : na
//   Instantiations      : ecc_dec
//   Synthesizable (y/n) : Yes
//   Other               :                                         
// -FHDR-------------------------------------------------------------


/*
 Wrapper that converts eip_ecc_enc bit order in altecc bit order
*/

module altecc_dec (
    d_i,              //ecoded data word input
    q_o,              //corrected information vector output
    syndrome_o,       //syndrome output
    sb_err_o,         //single bit error detected
    db_err_o,         //double bit error detected
    sb_fix_o          //single information bit error corrected
);


//---------------------------------------------------------
// Parameters
//---------------------------------------------------------
parameter K       = 8; //Information bit vector size
parameter LATENCY = 0; //0: no latency (combinatorial design)
                       //1: registered outputs
                       //2: registered inputs+outputs

//---------------------------------------------------------
// Local Parameters
//---------------------------------------------------------
localparam m = calculate_m(K);
localparam n = m + K;


//---------------------------------------------------------
// Inputs & Outputs
//---------------------------------------------------------
input  [n  :0] d_i;
output [K-1:0] q_o;
output [m  :0] syndrome_o;
output         sb_err_o;
output         db_err_o;
output         sb_fix_o;


//---------------------------------------------------------
// Functions
//---------------------------------------------------------
function integer calculate_m;
  input integer k;

  integer m;
begin
  m=1;
  while (2**m < m+k+1) m=m+1;

  calculate_m = m;
end
endfunction //calculate_m


function [n:1] gen_codeword;
  input [K-1:0] ibv;
  input [m  :1] pbv;

  integer i,j;
begin
    //This function puts the information and parity bits vector at the correct location

    //clear all bits
    gen_codeword = 0;

    //store information bits
    j=0; //information vector bit index
    for (i=1; i<= n; i=i+1)
    begin
        if (2**$clog2(i-1) != i)
        begin
            gen_codeword[i] = ibv[j];
            j = j+1;
        end
    end //next i


    //store parity bits
    //put parity vector at power-of-2 locations
    for (i=1; i<=m; i=i+1)
      gen_codeword[2**(i-1)] = pbv[i];
end
endfunction //gen_codeword


//---------------------------------------------------------
// Variables
//---------------------------------------------------------
wire [K-1:0] ibv;
wire [m-1:0] pbv;
wire         p0;
wire [n  :0] cw;


//---------------------------------------------------------
// Module Body
//---------------------------------------------------------
assign ibv = d_i[0 +: K];
assign pbv = d_i[K +: m];
assign p0  = d_i[n];
assign cw  = {p0, gen_codeword(ibv, pbv)};


ecc_dec #(K,LATENCY,0) ecc_dec_inst (
  .rst_ni     ( 1'b0       ),
  .clk_i      ( 1'b0       ),
  .clkena_i   ( 1'b0       ),
  .d_i        ( cw         ),
  .q_o        ( q_o        ),
  .syndrome_o ( syndrome_o ),
  .sb_err_o   ( sb_err_o   ),
  .db_err_o   ( db_err_o   ),
  .sb_fix_o   ( sb_fix_o   )
);

endmodule
