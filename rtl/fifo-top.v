module fifo1 #(
    parameter DSIZE = 8,
    parameter ASIZE = 4
)(
    output [DSIZE-1:0] rdata,
    output             wfull,
    output             rempty,
    input  [DSIZE-1:0] wdata,
    input              winc, wclk, wrst_n,
    input              rinc, rclk, rrst_n
);

    wire [ASIZE-1:0] waddr, raddr;
    wire [ASIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;

    // Synchronize read pointer into write clock domain
    sync_r2w sync_r2w (
        .wq2_rptr(wq2_rptr),
        .rptr(rptr),
        .wclk(wclk),
        .wrst_n(wrst_n)
    );

    // Synchronize write pointer into read clock domain
    sync_w2r sync_w2r (
        .rq2_wptr(rq2_wptr),
        .wptr(wptr),
        .rclk(rclk),
        .rrst_n(rrst_n)
    );

    // FIFO memory block
    fifomem #(DSIZE, ASIZE) fifomem (
        .rdata(rdata),
        .wdata(wdata),
        .waddr(waddr),
        .raddr(raddr),
        .wclken(winc),
        .wfull(wfull),
        .wclk(wclk)
    );

    // Read pointer logic and empty flag generation
    rptr_empty #(ASIZE) rptr_empty (
        .rempty(rempty),
        .raddr(raddr),
        .rptr(rptr),
        .rq2_wptr(rq2_wptr),
        .rinc(rinc),
        .rclk(rclk),
        .rrst_n(rrst_n)
    );

    // Write pointer logic and full flag generation
    wptr_full #(ASIZE) wptr_full (
        .wfull(wfull),
        .waddr(waddr),
        .wptr(wptr),
        .wq2_rptr(wq2_rptr),
        .winc(winc),
        .wclk(wclk),
        .wrst_n(wrst_n)
    );

endmodule
