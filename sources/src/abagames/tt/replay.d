/*
 * $Id: replay.d,v 1.1 2005/01/01 12:40:28 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. Some rights reserved.
 */
module abagames.tt.replay;

private import std.stdio;
private import abagames.util.sdl.recordablepad;

/**
 * Manage a replay data.
 */
public class ReplayData {
 public:
  static string dir = "replay";
  static const int VERSION_NUM = 20;
  PadRecord padRecord;
  float level;
  int grade;
  long seed;
 private:

  public void save(string fileName) {
    scope File fd;
    fd.open(dir ~ "/" ~ fileName, "wb");
    int write_data[1] = [VERSION_NUM];
    float write_data2[1] = [level];
    int write_data3[1] = [grade];
    long write_data4[1] = [seed];
    fd.rawWrite(write_data);
    fd.rawWrite(write_data2);
    fd.rawWrite(write_data3);
    fd.rawWrite(write_data4);
    padRecord.save(fd);
    fd.close();
  }

  public void load(string fileName) {
    scope File fd;
    fd.open(dir ~ "/" ~ fileName);
    int read_data[1];
    fd.rawRead(read_data);
    if (read_data[0] != VERSION_NUM)
      throw new Exception("Wrong version num");
    float read_data2[1];
    int read_data3[1];
    long read_data4[1];
    fd.rawRead(read_data2);
    fd.rawRead(read_data3);
    fd.rawRead(read_data4);
    level = read_data2[0];
    grade = read_data3[0];
    seed = read_data4[0];
    padRecord = new PadRecord;
    padRecord.load(fd);
    fd.close();
  }
}
