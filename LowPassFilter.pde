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
    }

    LowPassFilter(float cutoff)
    {
        this(cutoff,0.0f);
    }

    void setCutoff(float cutoff)
    {
        mCutoff = cutoff;
    }

    float write(float v)
    {
        float millis = millis();
        float timeSinceLastFrame = millis-mLastMillis;
        if (timeSinceLastFrame<5) {
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
        
};
