/*
 *  BSD 3-Clause License
 *  
 *  Copyright (c) 2016, Mango-Engine Team
 *  All rights reserved.
 *  
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *  
 *  * Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *  
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *  
 *  * Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *  
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 *  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 *  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module mango_engine.audio;

import mango_engine.game;
import mango_engine.event.core;

import blocksound.core;
import blocksound.audio;

import gl3n.linalg;

// Name conflict with mango_engine.audio.AudioManager
package alias blocksound_AudioManager = blocksound.audio.AudioManager;

class AudioManager {
    private shared GameManager _game;
    private shared blocksound_AudioManager _audioManager;

    @property GameManager game() @trusted nothrow { return cast(GameManager) _game; }

    @property blocksound_AudioManager audioManager() @trusted nothrow { return cast(blocksound_AudioManager) _audioManager; }

    this(GameManager game) @trusted {
        this._game = cast(shared) game;

        game.eventManager.registerEventHook(EngineCleanupEvent.classinfo.name,
            EventHook((Event e) {
                audioManager.cleanup();
            }, false) // We need to cleanup the context in the same thread it was created
        );

        blocksound_Init();

        _audioManager = cast(shared) new blocksound_AudioManager();
    }

    void setListenerLocation(vec3 location) @safe {
        audioManager.listenerLocation = Vec3(location.x, location.y, location.z);
    }

    void setGain(float gain) @safe {
        audioManager.gain = gain;
    }

    vec3 getListenerLocation() @safe {
        return vec3(audioManager.listenerLocation.x, audioManager.listenerLocation.y, audioManager.listenerLocation.z);
    }

    float getGain() @safe {
        return audioManager.gain;
    }
}