class LowPassFilter
{

    float mCutoff;
    float mLast;        
    float mCurrent;
    float mLastMillis;


    LowPassFilter(float cutoff)
    {
        mCutoff = cutoff;
        mLast = 0.0f;
        mCurrent= 0.0f;
    }

    void setCutoff(float cutoff)
    {
        mCutoff = cutoff;
    }

    float write(float v)
    {
        float millis = millis();
        float timeSinceLastFrame = millis-mLastMillis;
        mLast = mCurrent; 
        
        float sr = 1 / timeSinceLastFrame;
        float coef = mCutoff * TWO_PI / sr;
        if (coef > 1) 
            coef = 1;
        else if (coef < 0) 
            coef = 0;

        float feedback = 1 - coef;
       
        mCurrent = (coef * v) + (feedback * mLast); 
        mLastMillis = millis;
        return mCurrent;
    }

    float read()
    {
        return mCurrent;
    }
        
};
