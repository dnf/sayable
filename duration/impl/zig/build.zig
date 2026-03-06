const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sayableduration_mod = b.addModule("sayableduration", .{
        .root_source_file = b.path("src/sayableduration.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/test_format_duration.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sayableduration", .module = sayableduration_mod },
        },
    });

    const tests = b.addTest(.{
        .root_module = test_mod,
    });

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_tests.step);
}
