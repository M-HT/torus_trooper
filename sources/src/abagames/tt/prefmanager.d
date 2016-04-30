/*
 * $Id: prefmanager.d,v 1.1.1.1 2004/11/10 13:45:22 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. Some rights reserved.
 */
module abagames.tt.prefmanager;

private import std.stdio;
private import abagames.util.prefmanager;
private import abagames.tt.ship;

/**
 * Save/Load the high score.
 */
public class PrefManager: abagames.util.prefmanager.PrefManager {
 private:
  static const int VERSION_NUM = 10;
  static string PREF_FILE = "tt.prf";
  PrefData _prefData;

  public this() {
    _prefData = new PrefData;
  }

  public void load() {
    scope File fd;
    try {
      int read_data[1];
      fd.open(PREF_FILE);
      fd.rawRead(read_data);
      if (read_data[0] != VERSION_NUM)
        throw new Exception("Wrong version num");
      _prefData.load(fd);
    } catch (Exception e) {
      _prefData.init();
    } finally {
      fd.close();
    }
  }

  public void save() {
    scope File fd;
    try {
      fd.open(PREF_FILE, "wb");
      int write_data[1] = [VERSION_NUM];
      fd.rawWrite(write_data);
      _prefData.save(fd);
    } finally {
      fd.close();
    }
  }

  public PrefData prefData() {
    return _prefData;
  }
}

public class PrefData {
 private:
  GradeData[] gradeData;
  int _selectedGrade, _selectedLevel;

  public this() {
    gradeData = new GradeData[Ship.GRADE_NUM];
    foreach (ref GradeData gd; gradeData)
      gd = new GradeData;
  }

  public void init() {
    foreach (GradeData gd; gradeData)
      gd.init();
    _selectedGrade = 0;
    _selectedLevel = 1;
  }

  public void load(File fd) {
    foreach (GradeData gd; gradeData)
      gd.load(fd);
    int read_data[2];
    fd.rawRead(read_data);
    _selectedGrade = read_data[0];
    _selectedLevel = read_data[1];
  }

  public void save(File fd) {
    foreach (GradeData gd; gradeData)
      gd.save(fd);
    int write_data[2] = [_selectedGrade, _selectedLevel];
    fd.rawWrite(write_data);
  }

  public void recordStartGame(int gd, int lv) {
    _selectedGrade = gd;
    _selectedLevel = lv;
  }

  public void recordResult(int lv, int sc) {
    GradeData gd = gradeData[_selectedGrade];
    if (sc > gd.hiScore) {
      gd.hiScore = sc;
      gd.startLevel = _selectedLevel;
      gd.endLevel = lv;
    }
    if (lv > gd.reachedLevel) {
      gd.reachedLevel = lv;
    }
    _selectedLevel = lv;
  }

  public int getMaxLevel(int gd) {
    return gradeData[gd].reachedLevel;
  }

  public GradeData getGradeData(int gd) {
    return gradeData[gd];
  }

  public int selectedGrade() {
    return _selectedGrade;
  }

  public int selectedLevel() {
    return _selectedLevel;
  }
}

public class GradeData {
 public:
  int reachedLevel;
  int hiScore;
  int startLevel, endLevel;
 private:

  public void init() {
    reachedLevel = startLevel = endLevel = 1;
    hiScore = 0;
  }

  public void load(File fd) {
    int read_data[4];
    fd.rawRead(read_data);
    reachedLevel = read_data[0];
    hiScore = read_data[1];
    startLevel = read_data[2];
    endLevel = read_data[3];
  }

  public void save(File fd) {
    int write_data[4] = [reachedLevel, hiScore, startLevel, endLevel];
    fd.rawWrite(write_data);
  }
}
