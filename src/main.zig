const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;

pub fn main() !void {
    const original = try enableRawMode();
    defer _= disableRawMode(original);

    const stdinread = io.getStdIn().reader();
    const stdinwrite = io.getStdIn().writer();
    var buf: [1]u8 = undefined;

    while (true) {
        const n = try stdinread.read(buf[0..]);
        const c = buf[0];
        if (n != 1) break;
        if(buf[0] == 'q') break;


        if(std.ascii.isControl(c)){
            try stdinwrite.print("{d}\n", .{c});
        }
        else{
            try stdinwrite.print("{d} ('{c}')\n", .{c, c});
        }
    }
}

fn enableRawMode() !posix.termios{
    const fd = io.getStdIn().handle;
    const original = try posix.tcgetattr(fd);
    var raw = original;

    raw.lflag.ECHO = false;
    raw.lflag.ICANON = false;
    raw.lflag.ISIG = false;
    raw.iflag.IXON = false;

    try posix.tcsetattr(fd, .FLUSH, raw);
    return original;
}

fn disableRawMode(terminal: posix.termios) void{
    const fd = io.getStdIn().handle;
    posix.tcsetattr(fd, .FLUSH, terminal) catch |err|{
        std.log.err("{any}", .{err});
        std.posix.exit(1);
    };
}