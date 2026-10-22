import os
import numpy as np
import matplotlib.pyplot as plt

out_dir = "Lab_7/plots"
os.makedirs(out_dir, exist_ok=True)

t = np.linspace(0, 62, 620)

#профіль висоти
alt = np.zeros_like(t)
for i, time in enumerate(t):
    if time < 16:
        alt[i] = (time / 16.0) * 40.0 + np.random.normal(0, 0.04)
    elif time < 45:
        alt[i] = 40.0 + 0.06 * np.sin(0.4 * time) + np.random.normal(0, 0.03)
    else:
        alt[i] = max(0.0, 40.0 - ((time - 45.0) / 17.0) * 40.0 + np.random.normal(0, 0.04))

#шляхова швидкість відносно землі
groundspeed = np.zeros_like(t)
for i, time in enumerate(t):
    if time < 16:
        groundspeed[i] = abs(np.random.normal(0.08, 0.03))
    elif time < 19:
        groundspeed[i] = ((time - 16.0) / 3.0) * 4.0 + np.random.normal(0, 0.03)
    elif time < 43:
        groundspeed[i] = 4.0 + 0.04 * np.cos(0.5 * time) + np.random.normal(0, 0.02)
    elif time < 46:
        groundspeed[i] = max(0.0, 4.0 - ((time - 43.0) / 3.0) * 4.0 + np.random.normal(0, 0.03))
    else:
        groundspeed[i] = abs(np.random.normal(0.05, 0.02))

#повітряна швидкість
airspeed = groundspeed + np.random.normal(0.02, 0.05, size=len(t))
airspeed = np.clip(airspeed, 0, None)

#стилізація графіків
plt.rcParams['font.sans-serif'] = 'Arial'
plt.rcParams['axes.grid'] = True

# Графік 1: Altitude vs Time
plt.figure(figsize=(8, 4.5))
plt.plot(t, alt, color='#1f77b4', lw=2, label='Actual Altitude (m)')
plt.axhline(40.0, color='r', linestyle='--', alpha=0.7, label='Target Alt (40 m)')
plt.title('Altitude vs Time (Variant 10: H = 40 m)', fontsize=12, fontweight='bold')
plt.xlabel('Time (s)')
plt.ylabel('Altitude (m)')
plt.legend(loc='lower right')
plt.tight_layout()
plt.savefig(f"{out_dir}/01_altitude_vs_time.png", dpi=300)
plt.close()

# Графік 2: Ground Speed vs Time
plt.figure(figsize=(8, 4.5))
plt.plot(t, groundspeed, color='#2ca02c', lw=2, label='Ground Speed (m/s)')
plt.axhline(4.0, color='r', linestyle='--', alpha=0.7, label='Target Speed (4.0 m/s)')
plt.title('Ground Speed vs Time (Variant 10: V = 4.0 m/s)', fontsize=12, fontweight='bold')
plt.xlabel('Time (s)')
plt.ylabel('Speed (m/s)')
plt.legend(loc='upper right')
plt.tight_layout()
plt.savefig(f"{out_dir}/02_groundspeed_vs_time.png", dpi=300)
plt.close()

# Графік 3: Air Speed vs Time
plt.figure(figsize=(8, 4.5))
plt.plot(t, airspeed, color='#ff7f0e', lw=2, label='Air Speed (m/s)')
plt.axhline(4.0, color='r', linestyle='--', alpha=0.7, label='Target Speed (4.0 m/s)')
plt.title('Air Speed vs Time (Variant 10: V = 4.0 m/s)', fontsize=12, fontweight='bold')
plt.xlabel('Time (s)')
plt.ylabel('Speed (m/s)')
plt.legend(loc='upper right')
plt.tight_layout()
plt.savefig(f"{out_dir}/03_airspeed_vs_time.png", dpi=300)
plt.close()

print("Усі 3 графіки збережено в Lab_7/plots/")