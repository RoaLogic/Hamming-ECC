i/////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.          //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.    //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--'    //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  |\ `--.    //
//   `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---'    //
//                                             `---'               //
//   Error Correction and Detection Encoder                        //
//   Parameterized Extended Hamming Code Encoder                   //
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
// FILE NAME      : ecc_enc.sv
// DEPARTMENT     :
// AUTHOR         : rherveille
// AUTHOR'S EMAIL :
// ------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE        AUTHOR      DESCRIPTION
// 1.0     2017-04-07  rherveille  initial release
// ------------------------------------------------------------------
// KEYWORDS : HAMMING ERROR CORRECTION ENCODER                 
// ------------------------------------------------------------------
// PURPOSE  : Adds ECC bits to incoming data
// ------------------------------------------------------------------
// PARAMETERS
//  PARAM NAME        RANGE  DESCRIPTION              DEFAULT UNITS
//  K                 1+     Information Vector size  8
// ------------------------------------------------------------------
// REUSE ISSUES 
//   Reset Strategy      : none
//   Clock Domains       : none
//   Critical Timing     :
//   Test Features       : na
//   Asynchronous I/F    : yes
//   Scan Methodology    : na
//   Instantiations      : ecc_enc
//   Synthesizable (y/n) : Yes
//   Other               :                                         
// -FHDR-------------------------------------------------------------


/*
 Wrapper that converts eip_ecc_enc bit order in altecc bit order
*/

module altecc_enc (
    d_i,              //information bit vector input
    q_o,              //encoded data word output
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


//---------------------------------------------------------
// Inputs & Outputs
//---------------------------------------------------------
input  [K-1:0] d_i;
output [n  :0] q_o;


//---------------------------------------------------------
// Variables
//---------------------------------------------------------
wire [m:1] p;
wire       p0;


//---------------------------------------------------------
// Module Body
//---------------------------------------------------------
ecc_enc #(K) ecc_enc_inst (
  .d_i  (d_i ),
  .q_o  ( ),
  .p_o  ( p  ),
  .p0_o ( p0 )
);

assign q_o = {p0,p,d_i};

endmodule
