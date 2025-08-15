const std = @import("std");

const ds_map = i64;
const double = f64;
const string = [*:0]const u8;

const EventPerformAsyncFunc = *fn(i64, i64) callconv(.c) void;
var event_perform_async: EventPerformAsyncFunc = undefined;
const DsMapCreateFunc = *fn(i64) callconv(.c) ds_map;
var ds_map_create: DsMapCreateFunc = undefined;
const DsMapAddDoubleFunc = *fn(ds_map, string, double) callconv(.c) bool;
var _ds_map_add_double: DsMapAddDoubleFunc = undefined;
const DsMapAddStringFunc = *fn(ds_map, string, string) callconv(.c) bool;
var _ds_map_add_string: DsMapAddStringFunc = undefined;

pub fn ds_map_add_double(map: ds_map, key: string, val: double) void {
    _ = _ds_map_add_double(map, key, val);
}

pub fn ds_map_add_string(map: ds_map, key: string, val: string) void {
    _ = _ds_map_add_string(map, key, val);
}

pub export fn RegisterCallbacks(async_func: *u8, ds_map_create_func: *u8, ds_map_add_double_func: *u8, ds_map_add_string_func: *u8) f64 {
    event_perform_async = @ptrCast(async_func);
    ds_map_create = @ptrCast(ds_map_create_func);
    _ds_map_add_double = @ptrCast(ds_map_add_double_func);
    _ds_map_add_string = @ptrCast(ds_map_add_string_func);
    return 0.0;
}
