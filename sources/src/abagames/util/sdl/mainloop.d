/*
 * $Id: mainloop.d,v 1.1.1.1 2004/11/10 13:45:22 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. Some rights reserved.
 */
module abagames.util.sdl.mainloop;

private import bindbc.sdl;
private import abagames.util.logger;
private import abagames.util.rand;
private import abagames.util.prefmanager;
private import abagames.util.sdl.gamemanager;
private import abagames.util.sdl.screen;
private import abagames.util.sdl.input;
private import abagames.util.sdl.sound;
private import abagames.util.sdl.sdlexception;

/**
 * SDL main loop.
 */
public class MainLoop {
 public:
  const int INTERVAL_BASE = 16;
  int interval = INTERVAL_BASE;
  int accframe = 0;
  int maxSkipFrame = 5;
 private:
  Screen screen;
  Input input;
  GameManager gameManager;
  PrefManager prefManager;

  public this(Screen screen, Input input,
	      GameManager gameManager, PrefManager prefManager) {
    this.screen = screen;
    this.input = input;
    gameManager.setMainLoop(this);
    gameManager.setUIs(screen, input);
    gameManager.setPrefManager(prefManager);
    this.gameManager = gameManager;
    this.prefManager = prefManager;
  }

  // Initialize and load preference.
  private void initFirst() {
    prefManager.load();
    try {
      SoundManager.init();
    } catch (SDLInitFailedException e) {
      Logger.error(e);
    }
    gameManager.init();
  }

  // Quit and save preference.
  private void quitLast() {
    gameManager.close();
    SoundManager.close();
    prefManager.save();
    screen.closeSDL();
    SDL_Quit();
  }

  private bool done;

  public void breakLoop() {
    done = true;
  }

  public void loop() {
    done = false;
    long prvTickCount = 0;
    int i;
    long nowTick;
    int frame;
    SDL_Event event;

    screen.initSDL();
    initFirst();
    gameManager.start();

    while (!done) {
      while (!done && SDL_PollEvent(&event)) {
        switch (event.type) {
          case SDL_QUIT:
            breakLoop();
            break;
          case SDL_WINDOWEVENT:
            if (event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED) {
              if (event.window.data1 > 150 && event.window.data2 > 100)
                screen.resized(event.window.data1, event.window.data2);
            }
            break;
          default:
            break;
        }
      }
      input.handleEvents();
      nowTick = SDL_GetTicks();
      frame = cast(int) (nowTick-prvTickCount) / interval;
      if (frame <= 0) {
	frame = 1;
	SDL_Delay(cast(uint)(prvTickCount+interval-nowTick));
	if (accframe) {
	  prvTickCount = SDL_GetTicks();
	} else {
	  prvTickCount += interval;
	}
      } else if (frame > maxSkipFrame) {
	frame = maxSkipFrame;
	prvTickCount = nowTick;
      } else {
	prvTickCount += frame * interval;
      }
      for (i = 0; i < frame; i++) {
	gameManager.move();
      }
      screen.clear();
      gameManager.draw();
      screen.flip();
    }
    quitLast();
  }
}
