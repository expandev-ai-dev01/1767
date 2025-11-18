import { getLoadingSpinnerClassName } from './variants';
import type { LoadingSpinnerProps } from './types';

/**
 * @component LoadingSpinner
 * @summary Generic loading spinner component with size variants.
 * @domain core
 * @type ui-component
 * @category feedback
 */
export const LoadingSpinner = ({ size = 'md', className }: LoadingSpinnerProps) => {
  return (
    <div className="flex items-center justify-center w-full h-full">
      <div className={getLoadingSpinnerClassName({ size, className })} />
    </div>
  );
};
