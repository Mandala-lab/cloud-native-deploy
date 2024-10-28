import ReactDOM from 'react-dom/client'
import App from './App'
import {createBrowserRouter, RouterProvider} from 'react-router-dom'
import './styles.css'
import Register from './routes/Register.tsx'
import Login from './routes/Login.tsx'

const router = createBrowserRouter([
	{
		path: '/',
		element: <App />,
	},
	{
		path: '/register',
		element: <Register />,
	},
	{
		path: '/login',
		element: <Login />,
	},
])

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
	// <React.StrictMode>
	<RouterProvider router={router} />,
	// </React.StrictMode>,
)
