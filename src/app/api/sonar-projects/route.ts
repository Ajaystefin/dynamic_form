// src/app/api/sonar-projects/route.ts
import { NextRequest, NextResponse } from "next/server";
import axios from "axios";

export async function GET(req: NextRequest) {
  const orgKey = req.nextUrl.searchParams.get("orgKey");
  const token = req.nextUrl.searchParams.get("token");

  if (!orgKey || !token) {
    return NextResponse.json({ error: "Missing parameters" }, { status: 400 });
  }

  try {
    const res = await axios.get(
      `https://sonarcloud.io/api/components/search?organization=${orgKey}&qualifiers=TRK`,
      {
        headers: {
          Authorization: `Basic ${Buffer.from(`${token}:`).toString("base64")}`,
        },
      }
    );

    return NextResponse.json(res.data);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
