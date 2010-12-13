class LowPassFilter
{

    float mCutoff;
    float mLastOutput;
    float mLastInput;
    float mCurrentOutput;
    float mLastMillis;

    LowPassFilter(float cutoff, float v) {
        mCutoff = cutoff;
        mLastOutput = v;
        mLastInput = v;
        mCurrentOutput = v;
        mLastMillis = millis();
    }

    LowPassFilter(float cutoff) {
        this(cutoff,0.0f);
    }
    
    LowPassFilter() {
        this(1);
    }

    void setCutoff(float cutoff)
    {
        mCutoff = cutoff;
    }

    float write(float v)
    {
        float millis = millis();
        float timeSinceLastFrame = millis-mLastMillis;
        if (timeSinceLastFrame<30) {
          return mCurrentOutput;
        }
        mLastOutput = mCurrentOutput; 
        
        float sr = 1 / timeSinceLastFrame;
        float coef = mCutoff * TWO_PI / sr;
        if (coef > 1) 
            coef = 1;
        else if (coef < 0) 
            coef = 0;

        float feedback = 1 - coef;
       
        mCurrentOutput = (coef * v) + (feedback * mLastOutput); 
        mLastInput = v;
        mLastMillis = millis;
        return mCurrentOutput;
    }

    float read()
    {
      return write(mLastInput);
    }
    
    float set(float v) {
      mCurrentOutput = v;
      mLastInput = v;
      return v;
    }
        
};
