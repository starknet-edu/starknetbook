import React from "react";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ children, onClick, className, ...props }, ref) => {
    return (
      <button
        ref={ref}
        {...props}
        onClick={onClick}
        className={`px-2 py-1 bg-purple-900/90 rounded-md text-white disabled:opacity-30 ${className}`}
      >
        {children}
      </button>
    );
  },
);
