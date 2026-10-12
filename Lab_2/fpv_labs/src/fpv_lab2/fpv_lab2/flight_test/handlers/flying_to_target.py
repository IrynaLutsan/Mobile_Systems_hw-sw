import math
from typing import TYPE_CHECKING
from geometry_msgs.msg import TwistStamped
from ..flight_state import FlightState
from .handler import FlightStateHandler

if TYPE_CHECKING:
    from ..flight_test_node import FlightTestNode


class FlyingToTargetHandler(FlightStateHandler):
    MAX_SPEED = 1.0     
    KP = 0.7

    def handle(self, node: "FlightTestNode") -> None:
        if node.odometry is None:
            return

        curr_x = node.odometry.pose.pose.position.x
        curr_y = node.odometry.pose.pose.position.y
        curr_z = node.odometry.pose.pose.position.z

        if node.target_x is None:
            if curr_z < (node.TAKEOFF_ALTITUDE * 0.8):
                return

            node.initial_x = curr_x
            node.initial_y = curr_y
            node.target_x = node.initial_x + node.DELTA_X
            node.target_y = node.initial_y + node.DELTA_Y

            node.get_logger().info(f"=== INITIAL POSITION: x0={node.initial_x:.3f}, y0={node.initial_y:.3f} ===")
            node.get_logger().info(f"=== TARGET POSITION: xt={node.target_x:.3f}, yt={node.target_y:.3f} ===")

        dx = node.target_x - curr_x
        dy = node.target_y - curr_y
        distance = math.sqrt(dx**2 + dy**2)

        if distance <= node.TARGET_TOLERANCE:
            node.stop_drone()
            node.get_logger().info(
                f"=== TARGET REACHED! Final pos: x={curr_x:.3f}, y={curr_y:.3f}, Error: {distance:.3f} m ==="
            )
            node.get_logger().info("Initiating landing sequence...")
            node.state = FlightState.LANDING
            return

        speed_x = self.KP * dx
        speed_y = self.KP * dy

        speed_mag = math.sqrt(speed_x**2 + speed_y**2)
        if speed_mag > self.MAX_SPEED:
            speed_x = (speed_x / speed_mag) * self.MAX_SPEED
            speed_y = (speed_y / speed_mag) * self.MAX_SPEED

        twist = TwistStamped()
        twist.header.stamp = node.get_clock().now().to_msg()
        twist.header.frame_id = "map"
        twist.twist.linear.x = float(speed_x)
        twist.twist.linear.y = float(speed_y)
        twist.twist.linear.z = 0.0

        node.cmd_vel_publisher.publish(twist)
        node.get_logger().info(f"Dist: {distance:.2f} m | Pos: ({curr_x:.2f}, {curr_y:.2f}) | Vel: ({speed_x:.2f}, {speed_y:.2f})")