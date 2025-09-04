//! A simple bitmap data structure implementation.
//! It can be used to store a set of bits of a given fixed size with support to
//! set and clear ranges of bits as well as common bitwise operations.
//!
//! Bitwise operations are implemented using the bitwise AND, OR, XOR, NOT, and
//! AND NOT logical operators. Bitwise operations modifies the bitmap in place and
//! returns the modified bitmap. Bitwise operations can be performed on two bitmaps
//! of the same size.

const std = @import("std");

const Bitmap = struct {
    bits: []u8,
    dirty_bits: []u8,

    /// Initialise a bitmap with a given size.
    pub fn init(size: usize) Bitmap {
        return Bitmap{
            .bits = std.mem.zeroes([size]u8),
            .dirty_bits = std.mem.zeroes([size]u8),
        };
    }

    /// Deinitialise the bitmap.
    pub fn deinit(self: *Bitmap) void {
        self.bits.len = 0;
        self.dirty_bits.len = 0;
        self.bits = undefined;
        self.dirty_bits = undefined;
    }

    // -------- Write operations --------
    /// Set the bit at the given index to 1.
    pub fn set(self: *Bitmap, index: usize) void {
        self.dirty_bits[index / 8] |= @as(u8, 1 << (index % 8));
    }

    /// Clear the bit at the given index to 0.
    pub fn clear(self: *Bitmap, index: usize) void {
        self.dirty_bits[index / 8] &= ~(@as(u8, 1 << (index % 8)));
    }

    /// Get the bit at the given index.
    pub fn get(self: *Bitmap, index: usize) bool {
        return self.bits[index / 8] & (@as(u8, 1 << (index % 8))) != 0;
    }

    /// Set all bits to 1.
    pub fn set_all(self: *Bitmap) void {
        std.mem.set(u8, self.dirty_bits, 0xff);
    }

    /// Set a range of bits from index start to end to 1.
    pub fn set_range(self: *Bitmap, start: usize, end: usize) void {
        while (start <= end) : (start += 1) {
            self.set(start);
        }
    }

    /// Clear all bits to 0.
    pub fn clear_all(self: *Bitmap) void {
        std.mem.set(u8, self.dirty_bits, 0x00);
    }

    /// Clear a range of bits from index start to end to 0.
    pub fn clear_range(self: *Bitmap, start: usize, end: usize) void {
        while (start <= end) : (start += 1) {
            self.clear(start);
        }
    }

    /// Commit the dirty bits to the bits array.
    /// All read ops before commit won't return set/cleared bits.
    pub fn commit(self: *Bitmap) void {
        std.mem.copy(u8, self.bits, self.dirty_bits);
        self.clear_all();
    }

    // -------- Read operations --------
    /// Check if the bitmap is dirty.
    pub fn is_dirty(self: *Bitmap) bool {
        return self.bits.len != 0 and self.dirty_bits.len != 0;
    }

    /// Get the length of the bitmap.
    pub fn len(self: *Bitmap) usize {
        return self.bits.len;
    }

    /// Get the number of set bits in the bitmap.
    pub fn count_set_bits(self: *Bitmap) usize {
        var count: usize = 0;
        for (self.bits) |bit| {
            if (bit != 0) {
                count += 1;
            }
        }
        return count;
    }

    /// Get the number of cleared bits in the bitmap.
    pub fn count_clear_bits(self: *Bitmap) usize {
        return self.len() - self.count_set_bits();
    }

    // -------- Bitwise operations --------
    /// Get the bitwise AND of two bitmaps.
    pub fn get_and(self: *Bitmap, other: *Bitmap) void {
        for (self.bits, self.bits.len) |bit, i| {
            self.bits[i] = bit & other.bits[i];
        }
    }

    /// Get the bitwise OR of two bitmaps.
    pub fn get_or(self: *Bitmap, other: *Bitmap) void {
        for (self.bits, self.bits.len) |bit, i| {
            self.bits[i] = bit | other.bits[i];
        }
    }

    /// Get the bitwise XOR of two bitmaps.
    pub fn get_xor(self: *Bitmap, other: *Bitmap) void {
        for (self.bits, self.bits.len) |bit, i| {
            self.bits[i] = bit ^ other.bits[i];
        }
    }

    /// Get the bitwise NOT of a bitmap.
    pub fn get_not(self: *Bitmap) void {
        for (self.bits, self.bits.len) |bit, i| {
            self.bits[i] = ~bit;
        }
    }

    /// Get the bitwise AND NOT of two bitmaps.
    pub fn get_and_not(self: *Bitmap, other: *Bitmap) void {
        for (self.bits, self.bits.len) |bit, i| {
            self.bits[i] = bit & ~other.bits[i];
        }
    }
};

// TODO: tests
