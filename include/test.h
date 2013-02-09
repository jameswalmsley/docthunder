#ifndef _TEST_H_
#define _TEST_H_

/**
 *	@author		James Walmsley <james@fullfat-fs.co.uk>
 *	@defgroup	TEST	The Test Module
 *	@ingroup	TEST
 *	@copyright	(C) 2012 James Walmsley
 **/

#define MAX_PATH 1024 		///< Defines the maximum path length
#define 	MAX_PATH_LEN 		2048		///< Another max_path length



/**
 *	@brief	Program's main entry function.
 *	
 *	This is where all the magic starts.
 *
 *	@param	argc	The argument count.
 *	@param	argv	The array of argument strings.
 *
 *	@return	An error code.
 *
 **/
int main(int argc, char **argv);


int printf(char *format, ...);

/**
 *	@brief Copies a standard C string.
 *
 *	@param	dest	The destination string.
 *	@param	src		The source string.
 *
 *	@return	number of chars copied.
 **/
int strcpy(char *dest, const char *src);


#endif
