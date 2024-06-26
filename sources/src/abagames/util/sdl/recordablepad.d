/*
 * $Id: recordablepad.d,v 1.1 2005/01/01 12:40:28 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. Some rights reserved.
 */
module abagames.util.sdl.recordablepad;

private import std.stdio;
private import abagames.util.iterator;
private import abagames.util.sdl.pad;

/**
 * Pad that can record an input for a replay.
 */
public class RecordablePad: Pad {
 public:
  static const int REPLAY_END = -1;
  PadRecord padRecord;
 private:

  public void startRecord() {
    padRecord = new PadRecord;
    padRecord.clear();
  }

  public void record() {
    padRecord.add(lastDirState | lastButtonState);
  }

  public void startReplay(PadRecord pr) {
    padRecord = pr;
    padRecord.reset();
  }

  public int replay() {
    if (!padRecord.hasNext())
      return REPLAY_END;
    else
      return padRecord.next();
  }
}

public class PadRecord {
 private:
  struct Record {
    int series;
    int data;
  };
  Record[] record;
  int idx, series;

  public void clear() {
    record = null;
  }

  public void add(int d) {
    if (record && record[record.length - 1].data == d) {
      record[record.length - 1].series++;
    } else {
      Record r;
      r.series = 1;
      r.data = d;
      record ~= r;
    }
  }

  public void reset() {
    idx = 0;
    series = 0;
  }

  public bool hasNext() {
    if (idx >= record.length)
      return false;
    else
      return true;
  }

  public int next() {
    if (idx >= record.length)
      throw new Error("No more items");
    if (series <= 0)
      series = record[idx].series;
    int rsl = record[idx].data;
    series--;
    if (series <= 0)
      idx++;
    return rsl;
  }

  public void save(File fd) {
    int[1] write_data = [cast(int)(record.length)];
    int[2] write_data2;
    fd.rawWrite(write_data);
    foreach (Record r; record) {
      write_data2[0] = r.series;
      write_data2[1] = r.data;
      fd.rawWrite(write_data2);
    }
  }

  public void load(File fd) {
    clear();
    int[1] read_data;
    int[2] read_data2;
    fd.rawRead(read_data);
    for (int i = 0; i < read_data[0]; i++) {
      fd.rawRead(read_data2);
      Record r;
      r.series = read_data2[0];
      r.data = read_data2[1];
      record ~= r;
    }
  }
}
