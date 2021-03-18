const std = @import("std");
const c = @import("c.zig");

const log = std.log.scoped(.main);

const World = @import("world.zig").World;

var world: World = undefined;

pub fn main() anyerror!void {
    log.info("Start!", .{});

    world = try World.init(errorCallback, resizeCallback);
    defer world.deinit();

    log.debug("Entering main loop", .{});

    while (try world.run()) {
        try world.update();
    }

    log.info("Done!", .{});
}

export fn errorCallback(err: c_int, description: [*c]const u8) void {
    log.crit("Err: {} - {s}", .{ err, description });

    @panic("Some error occurred. Good luck!");
}

export fn resizeCallback(target: ?*c.GLFWwindow, width: c_int, height: c_int) void {
    log.debug("Size changed: {}x{}", .{ width, height });
}
