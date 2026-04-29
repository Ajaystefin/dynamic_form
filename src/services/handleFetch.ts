import axios from "axios";
import type { Project, FetchProjectsParams } from "@/types";

export const fetchProjects = async ({
  orgKey,
  token,
  addToast,
}: FetchProjectsParams): Promise<{ projects: Project[] } | { error: string }> => {
  if (!orgKey || !token) {
    return { error: "Organization and token are required" };
  }

  try {
    const res = await axios.get(`/api/sonar-projects?orgKey=${orgKey}&token=${token}`);

    if (res.status !== 200) {
      throw new Error(`Error fetching projects: ${res.statusText}`);
    }

    const list: Project[] = res.data.components;

    if (list.length === 0) {
      addToast?.({
        title: "No project found",
        text: "Check if the organization is correct and if you have access to the projects",
        color: "warning",
        iconType: "iInCircle",
      });
      return { projects: [] };
    }

    addToast?.({
      title: "Success!",
      text: `${list.length} project${list.length > 1 ? "s" : ""} found`,
      color: "success",
      iconType: "check",
    });

    return { projects: list };
  } catch (e: any) {
    console.error("Error fetching projects:", e);

    const errorMessage =
      axios.isAxiosError(e) && e.response?.status === 401
        ? "Invalid token or no permission"
        : "Connection error. Check your network and try again";

    addToast?.({
      title: "Oops! Something went wrong 😕",
      text: errorMessage,
      color: "danger",
      iconType: "alert",
    });

    return { error: errorMessage };
  }
};
