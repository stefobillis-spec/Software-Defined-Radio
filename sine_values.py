import numpy as np
import matplotlib.pyplot as plt

# Parameters
fs = 44100          # Sample rate (Hz)
f = 440            # Frequency (Hz)
duration = 2.0     # Duration in seconds

# Create time array in seconds
t = np.linspace(0, duration, int(fs * duration), endpoint=False)

# Generate sine wave values
signal = np.sin(2 * np.pi * f * t)

# Optional: Plot the sine wave
plt.figure(figsize=(10, 4))
plt.plot(t, signal)
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title(f'Sine Wave (f={f} Hz, duration={duration} s)')
plt.grid(True)
plt.show()

cycles = 2
resolution = 256
x = np.arange(0, 2*np.pi*cycles, 2*np.pi*cycles/resolution)
y = np.sin(x)