const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Component source paths (relative to project root)
    const age_src = b.path("../../../age/impl/zig/src/sayableage.zig");
    const date_src = b.path("../../../date/impl/zig/src/sayabledate.zig");
    const time_src = b.path("../../../time/impl/zig/src/sayabletime.zig");
    const duration_src = b.path("../../../duration/impl/zig/src/sayableduration.zig");

    // Create modules for each component
    const sayableage_mod = b.addModule("sayableage", .{
        .root_source_file = age_src,
        .target = target,
        .optimize = optimize,
    });

    const sayabledate_mod = b.addModule("sayabledate", .{
        .root_source_file = date_src,
        .target = target,
        .optimize = optimize,
    });

    const sayabletime_mod = b.addModule("sayabletime", .{
        .root_source_file = time_src,
        .target = target,
        .optimize = optimize,
    });

    const sayableduration_mod = b.addModule("sayableduration", .{
        .root_source_file = duration_src,
        .target = target,
        .optimize = optimize,
    });

    // Create the CLI module with all component imports
    const cli_mod = b.createModule(.{
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sayableage", .module = sayableage_mod },
            .{ .name = "sayabledate", .module = sayabledate_mod },
            .{ .name = "sayabletime", .module = sayabletime_mod },
            .{ .name = "sayableduration", .module = sayableduration_mod },
        },
    });

    // Build the CLI executable
    const exe = b.addExecutable(.{
        .name = "sayable",
        .root_module = cli_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |a| {
        run_cmd.addArgs(a);
    }
    const run_step = b.step("run", "Run the CLI");
    run_step.dependOn(&run_cmd.step);
}
