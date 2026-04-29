"use client";

import React from "react";

const HexLoader: React.FC = () => {
  return (
    <div className="socket">
      {Array.from({ length: 38 }, (_, i) => (
        <div key={i} className={`gel c${i + 1} r${Math.floor(i / 18) + 1}`}>
          <div className="hex-brick h1" />
          <div className="hex-brick h2" />
          <div className="hex-brick h3" />
        </div>
      ))}
      <div className="gel center-gel">
        <div className="hex-brick h1" />
        <div className="hex-brick h2" />
        <div className="hex-brick h3" />
      </div>
    </div>
  );
};

export default HexLoader;
