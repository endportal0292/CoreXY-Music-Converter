void keyPressed() {
  if (key == ESC) key = 0;
}

void mouseReleased() {
  if (mouseButton == LEFT) allfl = false;
}

boolean rectButton(float x, float y, float w, float h, float r, color colrect, color inactive, float ws, color colstrok, String text, float textsz, color coltext, boolean active) {
  pushStyle();
  colorMode(HSB, 255);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  boolean nav = false, prs = false;
  if (active && abs(mouseX - x) <= w / 2 && abs(mouseY - y) <= h / 2) nav = true;
  if (nav && mousePressed && mouseButton == LEFT) prs = true;
  if (ws >= 1) {
    strokeWeight(ws);
    stroke(colstrok);
  } else noStroke();
  fill(active ? !prs ? nav ? color(hue(colrect), saturation(colrect) - 30, brightness(colrect)) : colrect : color(hue(colrect), saturation(colrect) - 80, brightness(colrect)) : inactive);
  rect(x, y, w, h, r);
  fill(!prs ? nav ? color(hue(coltext), saturation(coltext) - 80, brightness(coltext)) : coltext : color(hue(coltext), saturation(coltext) - 120, brightness(coltext)));
  textSize(textsz);
  text(text, x, y - h * 0.1);
  popStyle();
  return prs;
}

boolean circleButton(float x, float y, float d, color colrect, float ws, color colstrok, String text, float textsz, color coltext, boolean active, color inarect) {
  pushStyle();
  colorMode(HSB, 255);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  boolean nav = false, prs = false;
  if (active && dist(x, y, mouseX, mouseY) <= d / 2) nav = true;
  if (nav && mousePressed && mouseButton == LEFT) prs = true;
  if (ws >= 1) {
    strokeWeight(ws);
    stroke(colstrok);
  } else noStroke();
  fill(active ? colrect : inarect);
  circle(x, y, d);
  fill(coltext);
  textSize(textsz);
  text(text, x, y - d / 2 * 0.1);
  popStyle();
  return prs;
}

class Text {
  String out = "", dsp = "";
  boolean ch, op, dcr, en, enc, aor;
  long tmr, tmr2, tmr3;
  int crs;
  Text() {
  }

  String update(float x, float y, float w, float h, float ws, color ws_col, float ts, String text, color colrect, color coltext, boolean active, color inarect) {
    pushStyle();
    colorMode(HSB, 255);
    rectMode(CENTER);
    textAlign(LEFT, TOP);
    textSize(ts);
    stroke(ws_col);
    strokeWeight(ws);
    boolean nav = false, prs = false;
    if (active && abs(mouseX - x) <= w / 2 && abs(mouseY - y) <= h / 2) {
      nav = true;
      aor = true;
      cursor(TEXT);
    } else if (aor) {
      aor = false;
      cursor(ARROW);
    }
    if (nav && mousePressed && mouseButton == LEFT) prs = true;
    if (prs && !ch) {
      ch = true;
      op = !op;
    } else if (!mousePressed && ch) ch = false;
    if (!nav && mousePressed && mouseButton == LEFT) op = false;
    fill(active ? colrect : inarect);
    rect(x, y, w, h);
    if (out.length() == 0 && !op) {
      out = text;
      crs = out.length();
      dsp = out;
    }
    if (op) {
      if (keyPressed) {
        if ((!en || millis() - tmr2 >= 500) && key != CODED) {
          if (!en) {
            en = true;
            tmr2 = millis();
          }
          if (key == BACKSPACE) {
            if (out.length() != 0 && crs != 0) {
              out = out.substring(0, crs - 1) + out.substring(crs, out.length());
              dcr = false;
              tmr = millis() - 500;
              crs--;
            }
          } else if (isDig(key) && out.length() < 5) {
            out = out.substring(0, crs) + key + out.substring(crs, out.length());
            dcr = false;
            tmr = millis() - 500;
            crs++;
          }
        }
        if ((!enc || millis() - tmr3 >= 500) && key == CODED) {
          if (!enc) {
            enc = true;
            tmr3 = millis();
          }
          if (keyCode == RIGHT) {
            crs = constrain(crs + 1, 0, out.length());
            dcr = false;
            tmr = millis() - 500;
          }
          if (keyCode == LEFT) {
            crs = constrain(crs - 1, 0, out.length());
            dcr = false;
            tmr = millis() - 500;
          }
        }
      } else if (!keyPressed) {
        en = false;
        enc = false;
      }
      if (millis() - tmr >= 500) {
        tmr = millis();
        dcr = !dcr;
        if (dcr) dsp = out.substring(0, crs) + "|" + out.substring(crs, out.length());
        else dsp = out;
      }
    } else dsp = out;
    fill(coltext);
    text(dsp, x + 0.05 * w, y + 0.05 * h, w, h);
    popStyle();
    return out;
  }

  boolean isDig(char k) {
    return (int(k) >= 48 && int(k) <= 57);
  }
}
