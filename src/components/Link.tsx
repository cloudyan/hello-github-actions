import React, { useState } from 'react'

const STATUS = {
  HOVERED: 'hovered',
  NORMAL: 'normal',
}

interface LinkProps {
  page: string;
  children?: JSX.Element;
}

function Link({ page, children }: LinkProps) {
  const [status, setStatus] = useState(STATUS.NORMAL)

  const onMouseEnter = () => {
    setStatus(STATUS.HOVERED)
  }

  const onMouseLeave = () => {
    setStatus(STATUS.NORMAL)
  }

  return (
    <a
      className={status}
      href={page || '#'}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
    >
      {children}
    </a>
  )
}

export default Link
