import { Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Header() {
  const { user } = useAuth();

  return (
    <div className="h-16 bg-white shadow flex justify-between items-center px-8">
      <h1 className="text-2xl font-bold">
        FleetFlow Dashboard
      </h1>

      <Link to="/profile" className="text-right hover:text-blue-600">
        <h2 className="font-semibold">
          {user ? `Welcome, ${user.full_name}` : "Loading account…"}
        </h2>

        <p className="text-gray-500">
          {user?.role || ""}
        </p>
      </Link>
    </div>
  );
}
