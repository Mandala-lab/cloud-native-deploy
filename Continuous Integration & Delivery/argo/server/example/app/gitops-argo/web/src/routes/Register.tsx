import {Button, TextField} from '@mui/material'
import SendIcon from '@mui/icons-material/Send'
import Box from '@mui/material/Box'

export default function Register() {
	const register = () => {
		fetch('http://127.0.0.1:8001/api/users/register', {
			method: 'POST',
			headers: {'Content-Type': 'application/json'},
		})
			.then(async data => {
				let res = await data.json()
				console.log(res)
			})
			.catch(err => console.log(err))
	}

	return <>
		<Box
			sx={{
				width: '400px',
				bc: '#fff',
				color: '#fff',
			}}
		>
			<TextField id="standard-basic" label="mobile" variant="standard" type="number" />
		</Box>

		<Box>
			<TextField id="" label="username" variant="standard" />
		</Box>

		<Box>
			<TextField id="" label="passowrd" variant="standard" type="password" />
		</Box>

		<Box>
			<Button
				onClick={() => register()}
				variant="contained"
				endIcon={<SendIcon />}
			>
				Register
			</Button>
		</Box>

	</>
}
